//
//  NSURL+Addition.m
//  chirp
//
//  Created by Dushyant Bansal on 12/11/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "NSURL+Addition.h"

@implementation NSURL (Addition)
+ (NSString *)composeUri:(NSString *)uri withParams:(NSDictionary *)params
{
    if ([uri rangeOfString:@"?"].location == NSNotFound)
    {
        uri = [uri stringByAppendingString:@"?"];
    }
    
    for (NSString *key in params.allKeys) {
        NSString *prefix = ([uri hasSuffix:@"?"] || [uri hasSuffix:@"&"]) ? @"" : @"&";
            
        uri = [uri stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@",prefix, key, params[key]]];
    }
    return uri;
}

+ (NSURL *)URLWithString:(NSString *)uri queryParams:(NSDictionary *)params
{
    NSString *uriWithParams = [self composeUri:uri withParams:params];
    return [NSURL URLWithString:uriWithParams];
}
@end
