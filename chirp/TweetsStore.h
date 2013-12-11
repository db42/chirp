//
//  TwitterFetcher.h
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetsStore : NSObject

- (void) fetchTweetsWithParams: (NSDictionary *)params withCallBackBlock:(void (^)(NSArray *tweetsData))callBackBlock;
- (void) addTweet:(NSString *)tweetText success:(void (^)(void))successBlock failure:(void (^)(void))failureBlock;

@end
