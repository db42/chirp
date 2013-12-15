//
//  FeedManager.m
//  chirp
//
//  Created by Dushyant Bansal on 12/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "FeedManager.h"
#import "TwitterFetcher.h"
#import "Tweet+Create.h"

@interface FeedManager ()
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;
@property BOOL isLoading;
@end

@implementation FeedManager

- (id)initWithManagedContext:(NSManagedObjectContext *)managedContext
{
  self = [super init];
  if (self)
  {
    self.managedContext = managedContext;
  }
  return self;
}

- (TwitterFetcher *)tweetFetcher
{
  if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
  return _tweetFetcher;
}

- (void)loadTweetsFromTweetsJSON:(NSArray *)tweetsData
{
  for (NSDictionary *data in tweetsData)
  {
    [Tweet tweetWithJSON:data inManagedContext:self.managedContext];
  }
}

- (void)fetchOlderTweets:(NSString *)lastTweetId success:(void (^)(void))success
{
  if (self.isLoading)
  {
    success();
    return;
  }
  
  self.isLoading = true;
  NSDictionary *params = @{@"count": @"20", @"max_id": lastTweetId};
  [self.tweetFetcher fetchTweetsWithParams:params success:^(NSArray *tweetsData)
   {
     [self.managedContext performBlock:^(void){
       [self loadTweetsFromTweetsJSON:tweetsData];
       self.isLoading = false;
       success();
     }];
   }];
}

- (void)fetchLatestTweets:(NSString *)mostRecentTweetId success:(void (^)(void))success
{
  NSDictionary *params;
  if (mostRecentTweetId)
    params = @{@"count": @"20", @"since_id": mostRecentTweetId};
  else
    params = @{@"count": @"20"};
  
  [self.tweetFetcher fetchTweetsWithParams:params success:^(NSArray *tweetsData) {
    [self.managedContext performBlock:^{
      [self loadTweetsFromTweetsJSON:tweetsData];
      success();
    }];
  }];
}

@end
