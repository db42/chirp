//
//  TwitterFetcher.h
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterFetcher : NSObject

- (id) initWithAuthToken: (NSString *)authToken;
- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock;
- (void) fetchTweetsWithParams: (NSDictionary *)params withCallBackBlock:(void (^)(NSArray *tweetsData))callBackBlock;
- (void) postTweetWithParams: (NSDictionary *)params withCallBack:(void (^)(NSDictionary *tweetData))callBack;

@end
