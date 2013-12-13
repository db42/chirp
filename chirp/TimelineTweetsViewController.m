//
//    NSInteger sectionIndex = [self.tableView numberOfSections] - 1;

//    NSInteger rowIndex = [self.tableView numberOfRowsInSection:sectionIndex] - 1;
//  DemoFeedCDVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TimelineTweetsViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet+Create.h"
#import "User+Create.h"
#import "TwitterFetcher.h"
#import "ProfileViewController.h"
#import "NetworkActivityIndicator.h"
#import "Constants.h"

static NSTimeInterval const TwitterPollIntervalSec = 60.0;
static NSString *const ComposeTweetVCSegueId = @"composeTweet";
static NSString *const AccessTokenObjectKey = @"access_token_object";
static NSString *const APPConsumerKey = @"HdYpIQHu000GiSJ0SPGGw";
static NSString *const APPConsumerSecret = @"uBOLiEdqobCBfUATnDEmBGUhp6Kci6gJaqmtssrThY";

@interface TimelineTweetsViewController ()
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshController;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) User *user;

@end

@implementation TimelineTweetsViewController

NSTimer *pullNewTweetsTimer;

- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}

- (void)extractOauthToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *keyPairs = [accessToken componentsSeparatedByString:@"&"];
    for (NSString *keyPair in keyPairs) {
        NSArray *keyValueArray = [keyPair componentsSeparatedByString:@"="];
        [userDefaults setObject:keyValueArray[1] forKey:keyValueArray[0]];
    }
    [userDefaults synchronize];
}

- (void)storeAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accessToken forKey:AccessTokenObjectKey];
    [userDefaults synchronize];
    
    [self extractOauthToken:accessToken];
}

- (NSString *)loadAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:AccessTokenObjectKey];
}

- (BOOL)isAuthTokenPresent
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:AuthTokenKey] != NULL;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self isAuthTokenPresent])
        return;
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]
                                         loginControllerWithCompletionHandler:^(BOOL success)
    {
        [self refreshView];
    }];
    
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:APPConsumerKey andSecret:APPConsumerSecret];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    
    if ([self isAuthTokenPresent])
        [self refreshView];
}

- (void)setManagedContext:(NSManagedObjectContext *)managedContext
{
    _managedContext = managedContext;
    [self loadFetchedResultController];
}

- (void) loadFetchedResultController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idString" ascending:false];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedContext sectionNameKeyPath:nil cacheName:nil];
}

- (IBAction)refreshView {
    [self.refreshController beginRefreshing];
    [self fetchAndLoadTweets];
}

- (void) fetchAndLoadTweets
{
    NSDictionary *params;
    if ([self mostRecentTweetId])
        params = @{@"count": @"20", @"since_id": [self mostRecentTweetId]};
    else
        params = @{@"count": @"20"};
        
    [[NetworkActivityIndicator sharedIndicator] show];
    [self.tweetFetcher fetchTweetsWithParams:params success:^(NSArray *tweetsData) {
        [[NetworkActivityIndicator sharedIndicator] hide];
        [self.managedContext performBlock:^{
            [self loadTweetsFromTweetsJSON:tweetsData];
        }];
    }];
}

- (NSString *) mostRecentTweetId
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (!self.fetchedResultsController)
    {
        return nil;
    }
    
    if ([[self.fetchedResultsController fetchedObjects] count])
    {
        Tweet *mostRecentTweet =[self.fetchedResultsController objectAtIndexPath:indexPath];
        if (mostRecentTweet)
            return mostRecentTweet.idString;
        return nil;
    }
    return nil;
}

- (void)loadTweetsFromTweetsJSON:(NSArray *)tweetsData
{
    for (NSDictionary *data in tweetsData)
    {
        [Tweet tweetWithJSON:data inManagedContext:self.managedContext];
    }
    
    if (pullNewTweetsTimer)
    {
        [pullNewTweetsTimer invalidate];
        pullNewTweetsTimer = nil;
    }
    pullNewTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:TwitterPollIntervalSec target:self selector:@selector(refreshView) userInfo:nil repeats:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.refreshController endRefreshing];
    });
}

bool isLoading = false;

- (NSString *)lastTweetId
{
    NSInteger lastSectionIndex = [[self.fetchedResultsController sections] count] - 1;
    if (lastSectionIndex < 0)
    {
        return nil;
    }
    
    NSInteger lastRowIndex = [[[self.fetchedResultsController sections] objectAtIndex:lastSectionIndex] numberOfObjects] - 1;
    if (lastRowIndex < 0)
    {
        return nil;
    }
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    Tweet *lastTweet =[self.fetchedResultsController objectAtIndexPath:lastIndex];
    return lastTweet.idString;
}

- (void)loadMoreRows
{
    NSString *lastTweetId = [self lastTweetId];
    if (isLoading || !lastTweetId)
        return;
    
    isLoading = true;
    [[NetworkActivityIndicator sharedIndicator] show];
    
    NSDictionary *params = @{@"count": @"20", @"max_id": lastTweetId};
    [self.tweetFetcher fetchTweetsWithParams:params success:^(NSArray *tweetsData)
     {
         [[NetworkActivityIndicator sharedIndicator] hide];
         [self.managedContext performBlock:^(void){
             [self loadTweetsFromTweetsJSON:tweetsData];
             isLoading = false;
         }];
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:ComposeTweetVCSegueId])
    {
        id destController = [segue destinationViewController];
        if ([destController respondsToSelector:@selector(setManagedContext:)])
        {
            [destController performSelector:@selector(setManagedContext:) withObject:self.managedContext];
        }
    }
}

@end
