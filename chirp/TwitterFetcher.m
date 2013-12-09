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


@interface TwitterFetcher()
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *tokenSecret;
@end

@implementation TwitterFetcher

- (id) initWithAuthToken: (NSString *)authToken
{
    self = [super init];
    if (self)
    {
        self.authToken = authToken;
    }
    return self;
}

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

- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock
{
    NSDictionary *params = @{@"screen_name": @"dushyant_db"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    NSString *uri = @"https://api.twitter.com/1.1/users/show.json";
    NSString *uriWithQueryString = [self composeUri:uri withParams:params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
    
    NSString *authHeader = [[FHSTwitterEngine sharedEngine] genAuthHeader:request verifierString:nil tokenString:self.authToken tokenSecretString:self.tokenSecret];
    
    [manager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [manager GET:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if (operation.responseData && operation.response.statusCode == 200)
        {
            NSError *err;
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
            callBackBlock(userData);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSString *a = [[NSString alloc] initWithData:operation.responseData encoding:NSASCIIStringEncoding];
        NSLog(@"%@", a);
    }];
}

//- (NSString *) genAuthHeader
//{
//    NSString *secret = @"uBOLiEdqobCBfUATnDEmBGUhp6Kci6gJaqmtssrThY";
//    NSString *consumerKey = @"HdYpIQHu000GiSJ0SPGGw";
//    NSString *nonce = @"";
//    NSString *signature = @"";
//    NSString *timestamp = @"";
//    NSString *authHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_version=\"1.0\"", consumerKey, nonce, self.authToken, timestamp, self.authToken];
//    return authHeader;
//}

- (NSString *)composeUri:(NSString *)uri withParams:(NSDictionary *)params
{
    if ([uri rangeOfString:@"?"].location == NSNotFound)
    {
        uri = [uri stringByAppendingString:@"?"];
    }
    
//    NSString *queryString = [[NSString alloc] init];
    for (NSString *key in params.allKeys) {
        NSString *prefix = ([uri hasSuffix:@"?"] || [uri hasSuffix:@"&"]) ? @"" : @"&";
            
        uri = [uri stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@",prefix, key, params[key]]];
    }
    return uri;
}

- (void)fetchTweetsWithParams:(void (^)(NSArray *))callBackBlock params:(NSDictionary *)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    NSString *uri = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSString *uriWithQueryString = [self composeUri:uri withParams:params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
    
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

- (void)postTweetWithParams:(NSDictionary *)params withCallBack:(void (^)(NSDictionary *))callBack
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    NSString *uri = @"https://api.twitter.com/1.1/statuses/update.json";
    NSString *uriWithQueryString = [self composeUri:uri withParams:params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uriWithQueryString]];
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
