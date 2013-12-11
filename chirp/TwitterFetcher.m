//
//  TwitterFetcher.m
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TwitterFetcher.h"
#import "AFNetworking.h"
#import "FHSTwitterEngine.h"

static NSString *const TWTUserProfileUrl = @"https://api.twitter.com/1.1/users/show.json";
static NSString *const TWTUserTimelineUrl = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
static NSString *const TWTTweetPostUrl = @"https://api.twitter.com/1.1/statuses/update.json";
static NSString *const TWTSignedInUserProfileUrl = @"https://api.twitter.com/1.1/account/verify_credentials.json";

@interface TwitterFetcher()
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *tokenSecret;
@end

@implementation TwitterFetcher

- (NSString *)authToken {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults objectForKey:@"oauth_token"];
}

- (NSString *)tokenSecret {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *tokenSecret = [defaults objectForKey:@"oauth_token_secret"];
  return tokenSecret;
}

- (void)fetchUserWithScreenName:(NSString *)screenName success:(void(^)(NSDictionary *userData))success {
  NSDictionary *params = @{@"screen_name": screenName};
  NSString *uriWithQueryString = [self composeUri:TWTUserProfileUrl withParams:params];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
  
  AFHTTPRequestOperationManager *manager = [self managerWithAuthHeader:request];
  [manager GET:TWTUserProfileUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
    if (operation.responseData && operation.response.statusCode == 200)
    {
      NSError *err;
      NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&err];
      success(userData);
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    NSString *response = [[NSString alloc] initWithData:operation.responseData
                                               encoding:NSASCIIStringEncoding];
    NSLog(@"Error fetching user profile from twitter - %@", response);
  }];
}

- (void)fetchSignedInUserWithSuccessHandler:(void(^)(NSDictionary *))success {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:TWTSignedInUserProfileUrl]];
  
  AFHTTPRequestOperationManager *manager = [self managerWithAuthHeader:request];
  [manager GET:TWTSignedInUserProfileUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
    if (operation.responseData && operation.response.statusCode == 200)
    {
      NSError *err;
      NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&err];
      success(userData);
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    NSString *response = [[NSString alloc] initWithData:operation.responseData
                                               encoding:NSASCIIStringEncoding];
    NSLog(@"Error fetching user profile from twitter - %@", response);
  }];
}

- (NSString *)composeUri:(NSString *)uri withParams:(NSDictionary *)params {
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

- (void)fetchTweetsWithParams:(NSDictionary *)params success:(void(^)(NSArray *tweetsData))success {
  NSString *uriWithQueryString = [self composeUri:TWTUserTimelineUrl withParams:params];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
  
  AFHTTPRequestOperationManager *manager = [self managerWithAuthHeader:request];
  [manager GET:TWTUserTimelineUrl
            parameters:params
               success:^(AFHTTPRequestOperation *operation, id responseObject){
    if (operation.responseData && operation.response.statusCode == 200)
    {
      NSError *err;
      NSArray *feedData = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&err];
      success(feedData);
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    NSString *response = [[NSString alloc] initWithData:operation.responseData encoding:NSASCIIStringEncoding];
    NSLog(@"Error fetching user timeline tweets from twitter - %@", response);
  }];
}

- (AFHTTPRequestOperationManager *)managerWithAuthHeader:(NSMutableURLRequest *)request {
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
  NSString *authHeader = [[FHSTwitterEngine sharedEngine] genAuthHeader:request
                                                         verifierString:nil
                                                            tokenString:self.authToken
                                                      tokenSecretString:self.tokenSecret];
  [manager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
  return manager;
}

- (void)postTweetWithParams:(NSDictionary *)params success:(void(^)(NSDictionary *tweetData))success {
  NSString *uriWithQueryString = [self composeUri:TWTTweetPostUrl withParams:params];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
  request.HTTPMethod = @"POST";
  
  AFHTTPRequestOperationManager *manager = [self managerWithAuthHeader:request];
  [manager POST:TWTTweetPostUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
    if (operation.responseData && operation.response.statusCode == 200)
    {
      NSError *err;
      NSDictionary *tweetData = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
      success(tweetData);
    }
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    NSString *response = [[NSString alloc] initWithData:operation.responseData encoding:NSASCIIStringEncoding];
    NSLog(@"Error posting a tweet - %@", response);
  }];
}

@end