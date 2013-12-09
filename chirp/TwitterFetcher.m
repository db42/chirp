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

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TwitterFetcher()
@property (nonatomic) ACAccountStore *accountStore;
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

- (NSString *)tokenSecret
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenSecret = [defaults objectForKey:@"oauth_token_secret"];
    return tokenSecret;
}

- (ACAccountStore *)accountStore
{
    if (!_accountStore)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSURL *feedUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json" relativeToURL:Nil];
    
    NSDictionary *params = @{@"screen_name": @"dushyant_db"};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feedUrl parameters:params];
             
             NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
             
             [request setAccount:[twitterAccounts lastObject]];
             
             [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 if (responseData && urlResponse.statusCode == 200)
                 {
                     NSError *err;
                     NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
                     callBackBlock(feedDict);
                 }
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

- (void)fetchTweetsWithParams:(void (^)(NSArray *))callBackBlock params:(NSDictionary *)params
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    NSString *uri = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri]];
    
    NSString *authHeader = [[FHSTwitterEngine sharedEngine] genAuthHeader:request verifierString:nil tokenString:self.authToken tokenSecretString:self.tokenSecret];
    
    [manager.requestSerializer setValue:authHeader forHTTPHeaderField:@"Authorization"];
    
    [manager GET:uri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
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

    
//    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    
//    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error)
//     {
//         if (granted)
//         {
//             NSURL *feedUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"relativeToURL:Nil];
//             SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feedUrl parameters:params];
//             
//             NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
//             
//             [request setAccount:[twitterAccounts lastObject]];
//             
//             [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//                 
//                 if (responseData && urlResponse.statusCode == 200)
//                 {
//                     NSError *err;
//                     NSArray *feedDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
//                     callBackBlock(feedDict);
//                 }
//             }];
//             
//         }
//     }];
}

-(void)fetchTweetsWithParams:(NSDictionary *)params withCallBackBlock:(void (^)(NSArray * tweetsData))callBackBlock
{
    [self fetchTweetsWithParams:callBackBlock params:params];
}

- (void)postTweetWithParams:(NSDictionary *)params withCallBack:(void (^)(NSDictionary *))callBack
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSURL *feedUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json" relativeToURL:Nil];
             SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:feedUrl parameters:params];
             
             NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
             
             [request setAccount:[twitterAccounts lastObject]];
             
             [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 if (responseData && urlResponse.statusCode == 200)
                 {
                     NSError *err;
                     NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
                     callBack(feedDict);
                 }
             }];
             
         }
     }];
    
}

@end
