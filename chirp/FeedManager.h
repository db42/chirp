//
//  FeedManager.h
//  chirp
//
//  Created by Dushyant Bansal on 12/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedManager : NSObject

- (id)initWithManagedContext:(NSManagedObjectContext *)managedContext;
- (void)fetchOlderTweets:(NSString *)lastTweetId success:(void(^)(void))success;
- (void)fetchLatestTweets:(NSString *)mostRecentTweetId success:(void(^)(void))success;
@end
