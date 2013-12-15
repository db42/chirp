//
//  AccessTokenManager.m
//  chirp
//
//  Created by Dushyant Bansal on 12/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "AccessTokenManager.h"
#import "Constants.h"

static NSString *const AccessTokenObjectKey = @"access_token_object";

@implementation AccessTokenManager
- (BOOL)isAuthTokenPresent
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults objectForKey:AuthTokenKey] != NULL;
}

- (void)extractOauthToken:(NSString *)accessToken
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSArray *keyPairs = [accessToken componentsSeparatedByString:@"&"];
  for (NSString *keyPair in keyPairs) {
    NSArray *keyValueArray = [keyPair componentsSeparatedByString:@"="];
    [userDefaults setObject:keyValueArray[1] forKey:keyValueArray[0]];
  }
  [userDefaults synchronize];
}

- (void)storeAccessToken:(NSString *)accessToken
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:accessToken forKey:AccessTokenObjectKey];
  [userDefaults synchronize];
  
  [self extractOauthToken:accessToken];
}

- (NSString *)loadAccessToken
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults objectForKey:AccessTokenObjectKey];
}

@end
