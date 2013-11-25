//
//  TwitterFetcher.m
//  chirp
//
//  Created by Dushyant Bansal on 11/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TwitterFetcher.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TwitterFetcher()
@property (nonatomic) ACAccountStore *accountStore;
@end

@implementation TwitterFetcher

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


- (void)fetchTweetsWithParams:(void (^)(NSArray *))callBackBlock params:(NSDictionary *)params
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSURL *feedUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"relativeToURL:Nil];
             SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feedUrl parameters:params];
             
             NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
             
             [request setAccount:[twitterAccounts lastObject]];
             
             [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 if (responseData && urlResponse.statusCode == 200)
                 {
                     NSError *err;
                     NSArray *feedDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
                     callBackBlock(feedDict);
                 }
             }];
             
         }
     }];
}

-(void)fetchTweets:(int)count withCallBackBlock:(void (^)(NSArray * tweetsData))callBackBlock
{
    NSDictionary *params = @{@"screen_name": @"dushyant_db", @"count": @"20"};
    
    [self fetchTweetsWithParams:callBackBlock params:params];
}

- (void)fetchPreviousTweets:(int)count withId:(NSString *)id withCallBackBlock:(void (^)(NSArray *))callBackBlock
{
    NSDictionary *params = @{@"screen_name": @"dushyant_db", @"count": [NSString stringWithFormat:@"%d", count], @"max_id": id};
    
    [self fetchTweetsWithParams:callBackBlock params:params];
}

@end
