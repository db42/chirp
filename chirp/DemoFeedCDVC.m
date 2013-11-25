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

@interface DemoFeedCDVC ()
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshController;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) User *user;

@end

@implementation DemoFeedCDVC


- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}

- (void)viewDidLoad
{
    if (!self.managedContext)
    {
        [self initManagedContext];
        
        //load tweets
        [self refreshView];
    }
}

- (void) initManagedContext
{
    if (!self.managedContext)
    {
        NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        fileUrl = [fileUrl URLByAppendingPathComponent:@"demo doc"];
        UIManagedDocument *document= [[UIManagedDocument alloc] initWithFileURL:fileUrl];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]])
        {
            self.managedContext = document.managedObjectContext;
        }
        else
        {
            [document saveToURL:fileUrl
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success){
                if (success)
                {
                    self.managedContext = document.managedObjectContext;
                }
            }];
        }
    }
}

- (IBAction)refreshView {
    [self.refreshController beginRefreshing];
    [self fetchAndLoadTweets];
}

- (void) fetchAndLoadTweets
{
    [self.tweetFetcher fetchTweets:20 withCallBackBlock:^(NSArray *tweetsData) {
        [self loadTweetsFromTweetsDict:tweetsData];
    }];
}

- (void)loadTweetsFromTweetsDict:(NSArray *)tweetsData
{
    for (NSDictionary *data in tweetsData)
    {
        Tweet *tweet = [Tweet initWithDict:data withManagedContext:self.managedContext];
        
        NSLog(@"tweet parsing - %@ %@ %@", tweet.id_str, tweet.text, tweet.composer.name);
        NSError *error = nil;
        [self.managedContext save:&error];
    }
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
    NSString *lastTweetId = lastTweet.id_str;
    if (lastTweetId)
    {
        [self.tweetFetcher fetchPreviousTweets:20 withId:lastTweetId withCallBackBlock:^(NSArray *tweetsData) {
            [self loadTweetsFromTweetsDict:tweetsData];
//            loading = false;
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"setUserScreenName"])
    {
        id destController = [segue destinationViewController];
        if ([destController respondsToSelector:@selector(setUserScreenName:)])
        {
            [destController performSelector:@selector(setUserScreenName:) withObject:@"dushyant_db"];
            [destController performSelector:@selector(setManagedContext:) withObject:self.managedContext];
        }
    }
}
@end
