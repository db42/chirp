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

static NSInteger networkOps = 0;

+ (void)show
{
    @synchronized(self)
    {
        networkOps++;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+ (void)hide
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
