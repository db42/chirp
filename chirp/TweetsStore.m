//
//  TwitterFetcher.m
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetsStore.h"
#import "AFNetworking.h"
#import "FHSTwitterEngine.h"
#import "NSURL+Addition.h"
#import "Tweet+Create.h"


@interface TweetsStore()
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *tokenSecret;
@end

@implementation TweetsStore

- (NSString *)authToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"oauth_token"];
}

- (NSString *)tokenSecret
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenSecret = [defaults objectForKey:@"oauth_token_secret"];
    return tokenSecret;
}

- (void)fetchTweetsWithParams:(void (^)(NSArray *))callBackBlock params:(NSDictionary *)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    NSString *uri = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri queryParams:params]];
    
    NSString *authHeader = [[FHSTwitterEngine sharedEngine] genAuthHeader:request verifierString:nil tokenString:self.authToken tokenSecretString:self.tokenSecret];
    
    [manager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [manager GET:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (operation.responseData && operation.response.statusCode == 200)
        {
            NSError *err;
            NSArray *feedDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
            callBackBlock(feedDict);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSString *a = [[NSString alloc] initWithData:operation.responseData encoding:NSASCIIStringEncoding];
        NSLog(@"%@", a);
    }];
}

-(void)fetchTweetsWithParams:(NSDictionary *)params withCallBackBlock:(void (^)(NSArray * tweetsData))callBackBlock
{
    [self fetchTweetsWithParams:callBackBlock params:params];
}

- (void)addTweet:(NSString *)tweetText success:(void (^)(void))successBlock failure:(void (^)(void))failureBlock
{
    NSDictionary *params = @{@"status": tweetText};
    [self postTweetWithParams:params withCallBack:^(NSDictionary *tweetData){
        [Tweet tweetWithJSON:tweetData inManagedContext:self.managedContext];
        
    }];
}

- (void)postTweetWithParams:(NSDictionary *)params withCallBack:(void (^)(NSDictionary *))callBack
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    NSString *uri = @"https://api.twitter.com/1.1/statuses/update.json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri queryParams:params]];
    request.HTTPMethod = @"POST";
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri]];
    
    NSString *authHeader = [[FHSTwitterEngine sharedEngine] genAuthHeader:request verifierString:nil tokenString:self.authToken tokenSecretString:self.tokenSecret];
    
    [manager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [manager POST:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (operation.responseData && operation.response.statusCode == 200)
        {
            NSError *err;
            NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
            callBack(feedDict);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSString *a = [[NSString alloc] initWithData:operation.responseData encoding:NSASCIIStringEncoding];
        NSLog(@"%@", a);
    }];
    
}

@end
