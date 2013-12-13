//
//  NetworkActivityIndicator.m
//  chirp
//
//  Created by Dushyant Bansal on 11/26/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "NetworkActivityIndicator.h"
@interface NetworkActivityIndicator()
@end

@implementation NetworkActivityIndicator

NSInteger networkOps = 0;

+ (id)sharedIndicator {
  static id sharedIndicator;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    sharedIndicator = [[self alloc] init];
  });
  return sharedIndicator;
}

- (void)show
{
    @synchronized(self)
    {
        networkOps++;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hide
{
    @synchronized(self)
    {
        if (networkOps)
            networkOps--;
    }
    
    if (!networkOps)
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
