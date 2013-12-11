//
//  UsersStore.m
//  chirp
//
//  Created by Dushyant Bansal on 12/11/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "UsersStore.h"
#import "AFNetworking.h"
#import "FHSTwitterEngine.h"
#import "NSURL+Addition.h"

@interface UsersStore()
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *tokenSecret;
@end

@implementation UsersStore
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

- (User *)userWithScreenName:(NSString *)screenName
{
    User *user;
        //fetch from db
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"screenName == %@", screenName];
        
        NSError *error;
        NSArray *resultUsers = [self.managedContext executeFetchRequest:request error:&error];
        
        if (resultUsers != nil && resultUsers.count == 1)
        {
            user = [resultUsers lastObject];
        }
        else
        {
            //fetch from twitterFetcher
            [self fetchUserWithScreenName:screenName withCallBackBlock:^(NSDictionary *tweetData){
                user = [User userWithJSON:tweetData inManagedContext:self.managedContext];
//                NSLog("%@", tweetData);
            }];
            
        }
}
- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock
{
    NSDictionary *params = @{@"screen_name": @"dushyant_db"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    NSString *uri = @"https://api.twitter.com/1.1/users/show.json";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri queryParams:params]];
    
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

@end
