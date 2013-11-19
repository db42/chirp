//
//  TwitterFetcher.h
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterFetcher : NSObject

- (void) fetchTweets: (int)count withCallBackBlock:(void (^)(NSArray *tweetsData))callBackBlock;

@end
