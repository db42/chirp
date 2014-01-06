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
#import "Tweet.h"
#import "ProfileViewController.h"
#import "NetworkActivityIndicator.h"
#import "FeedManager.h"
#import "AccessTokenManager.h"

static NSTimeInterval const TwitterPollIntervalSec = 60.0;
static NSString *const ComposeTweetVCSegueId = @"composeTweet";
static NSString *const APPConsumerKey = @"HdYpIQHu000GiSJ0SPGGw";
static NSString *const APPConsumerSecret = @"uBOLiEdqobCBfUATnDEmBGUhp6Kci6gJaqmtssrThY";

@interface TimelineTweetsViewController ()
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshController;
@property (strong, nonatomic) FeedManager *feedManager;
@property (strong, nonatomic) AccessTokenManager *accessTokenManager;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSTimer *pullNewTweetsTimer;
@end

@implementation TimelineTweetsViewController
- (FeedManager *)feedManager
{
  if (!_feedManager)
    _feedManager = [[FeedManager alloc] initWithManagedContext:self.managedContext];
  return _feedManager;
}

- (AccessTokenManager *)accessTokenManager
{
  if (!_accessTokenManager)
    _accessTokenManager = [[AccessTokenManager alloc] init];
  return _accessTokenManager;
}

- (void)viewDidAppear:(BOOL)animated
{
  if ([self.accessTokenManager isAuthTokenPresent])
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
  [[FHSTwitterEngine sharedEngine] setDelegate:self.accessTokenManager];
  
  if ([self.accessTokenManager isAuthTokenPresent])
    return;
  
  UIViewController *loginController = [[FHSTwitterEngine sharedEngine]
                                       loginControllerWithCompletionHandler:^(BOOL success)
                                       {
                                         [self refreshView];
                                       }];
  [self presentViewController:loginController animated:YES completion:nil];
//  if ([self.accessTokenManager isAuthTokenPresent])
//    [self refreshView];
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
  [[NetworkActivityIndicator sharedIndicator] show];
  
  [self.feedManager fetchLatestTweets:[self mostRecentTweetId] success:^(void){
    [[NetworkActivityIndicator sharedIndicator] hide];
    dispatch_async(dispatch_get_main_queue(), ^(void){
      [self.refreshController endRefreshing];
        });
    [self resetPullNewTweetsTimer];
  }];
}

- (void)resetPullNewTweetsTimer
{
  if (self.pullNewTweetsTimer)
  {
    [self.pullNewTweetsTimer invalidate];
    self.pullNewTweetsTimer = nil;
  }
  self.pullNewTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:TwitterPollIntervalSec
                                                             target:self
                                                           selector:@selector(refreshView)
                                                           userInfo:nil
                                                            repeats:NO];
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
  if (!lastTweetId)
    return;
  
  [[NetworkActivityIndicator sharedIndicator] show];
  [self.feedManager fetchOlderTweets:lastTweetId success:^(void){
     [[NetworkActivityIndicator sharedIndicator] hide];
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
