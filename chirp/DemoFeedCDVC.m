//
//    NSInteger sectionIndex = [self.tableView numberOfSections] - 1;

//    NSInteger rowIndex = [self.tableView numberOfRowsInSection:sectionIndex] - 1;
//  DemoFeedCDVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "DemoFeedCDVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet+Create.h"
#import "User+Create.h"
#import "TwitterFetcher.h"
#import "ProfileVC.h"
#import "NetworkActivityIndicator.h"
#import "Manager.h"

#define TWITTER_POLL_INTERVAL_SEC 60.0

@interface DemoFeedCDVC ()
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshController;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) User *user;

@end

@implementation DemoFeedCDVC

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
    [userDefaults setObject:accessToken forKey:@"access_token_object"];
    [userDefaults synchronize];
    
    [self extractOauthToken:accessToken];
}

- (NSString *)loadAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"access_token_object"];
}

- (NSString *)loadOauthToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"oauth_token"];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self loadAccessToken])
        return;
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success){
         NSLog(@"completed");
        [self refreshView];
    }];
    
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    NSString *consumerKey = @"HdYpIQHu000GiSJ0SPGGw";
    NSString *secretKey = @"uBOLiEdqobCBfUATnDEmBGUhp6Kci6gJaqmtssrThY";
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:consumerKey andSecret:secretKey];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    
//   [self refreshView];
    
//    if (!self.managedContext)
//    {
//    }
}

- (void)setManagedContext:(NSManagedObjectContext *)managedContext
{
    [super setManagedContext: managedContext];
//    [self refreshView];
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
        
    [NetworkActivityIndicator show];
    [self.tweetFetcher fetchTweetsWithParams:params withCallBackBlock:^(NSArray *tweetsData) {
        [NetworkActivityIndicator hide];
        [self.managedContext performBlock:^{
            [self loadTweetsFromTweetsDict:tweetsData];
        }];
    }];
}

- (NSString *) mostRecentTweetId
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if (!self.resultController)
    {
        return nil;
    }
    
    if ([[self.resultController fetchedObjects] count])
    {
        Tweet *mostRecentTweet =[self.resultController objectAtIndexPath:indexPath];
        if (mostRecentTweet)
            return mostRecentTweet.idString;
        return nil;
    }
    return nil;
}

- (void)loadTweetsFromTweetsDict:(NSArray *)tweetsData
{
    for (NSDictionary *data in tweetsData)
    {
        Tweet *tweet = [Tweet initWithDict:data withManagedContext:self.managedContext];
        
        NSLog(@"tweet parsing - %@ %@ %@", tweet.idString, tweet.text, tweet.composer.name);
        //        NSError *error = nil;
        //        [self.managedContext save:&error];
    }
    
    if (pullNewTweetsTimer)
    {
        [pullNewTweetsTimer invalidate];
        pullNewTweetsTimer = nil;
    }
    pullNewTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:TWITTER_POLL_INTERVAL_SEC target:self selector:@selector(refreshView) userInfo:nil repeats:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.refreshController endRefreshing];
    });
}

bool loading = false;

- (void)loadMoreRows
{
    NSInteger sectionIndex = [[self.resultController sections] count] - 1;
    if (sectionIndex < 0)
    {
        return;
    }
    
    NSInteger rowIndex = [[[self.resultController sections] objectAtIndex:sectionIndex] numberOfObjects] - 1;
    if (rowIndex < 0)
    {
        return;
    }
    
    if (loading)
        return;
    
    loading = true;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    
    Tweet *lastTweet =[self.resultController objectAtIndexPath:indexPath];
    NSString *lastTweetId = lastTweet.idString;
    if (lastTweetId)
    {
        NSDictionary *params = @{@"count": @"20", @"max_id": lastTweetId};
        [NetworkActivityIndicator show];
        [self.tweetFetcher fetchTweetsWithParams:params withCallBackBlock:^(NSArray *tweetsData) {
            [NetworkActivityIndicator hide];
            [self.managedContext performBlock:^(void){
                [self loadTweetsFromTweetsDict:tweetsData];
                loading = false;
            }];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"setManagedContext"])
    {
        id destController = [segue destinationViewController];
        if ([destController respondsToSelector:@selector(setManagedContext:)])
        {
            [destController performSelector:@selector(setManagedContext:) withObject:self.managedContext];
        }
    }
}

@end
