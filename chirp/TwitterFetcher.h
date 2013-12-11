//
//  TwitterFetcher.h
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterFetcher : NSObject

- (void) fetchUserWithScreenName: (NSString *)screenName success:(void (^)(NSDictionary * userData))success;
- (void) fetchSignedInUserWithSuccessHandler:(void (^)(NSDictionary * userData))success;
- (void) fetchTweetsWithParams: (NSDictionary *)params success:(void (^)(NSArray *tweetsData))success;
- (void) postTweetWithParams: (NSDictionary *)params success:(void (^)(NSDictionary *tweetData))success;

@end
