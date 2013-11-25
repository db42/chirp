//
//  TwitterFetcher.h
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterFetcher : NSObject

- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock;
- (void) fetchTweets: (int)count withCallBackBlock:(void (^)(NSArray *tweetsData))callBackBlock;
- (void) fetchPreviousTweets:(int)count withId:(NSString *)id withCallBackBlock:(void (^)(NSArray *tweetsData))callBackBlock;

@end
