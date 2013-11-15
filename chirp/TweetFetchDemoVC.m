//
//  TweetFetchDemoVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/13/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetFetchDemoVC.h"
#import "Social/Social.h"
#import "Accounts/Accounts.h"
#import "Tweet+Create.h"
#import "User.h"


@interface TweetFetchDemoVC ()

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) NSManagedObjectContext *managedContext;


@end

@implementation TweetFetchDemoVC

//- (NSManagedObjectContext *)managedContext
//{


- (void) setUpManagedContext
{
    if (!self.managedContext)
    {
        //create managedcontext
        NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        fileUrl = [fileUrl URLByAppendingPathComponent:@"demo doc"];
        UIManagedDocument *document= [[UIManagedDocument alloc] initWithFileURL:fileUrl];
        
        //if file exists
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]])
        {
            self.managedContext = document.managedObjectContext;
        }
        else
        {
//            NSLog(@"function %s ", __PRETTY_FUNCTION__);
            //create file
            [document saveToURL:fileUrl
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success){
                if (success)
                {
                    self.managedContext = document.managedObjectContext;
                }
            }];
        }
    }
    
}
- (ACAccountStore *)accountStore
{
    if (!_accountStore)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self setUpManagedContext];
    [self fetchTweets];
}

- (void) fetchTweets
{
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
            NSURL *feedUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"relativeToURL:Nil];
            NSDictionary *params = @{@"screen_name": @"dushyant_db", @"count": @"3"};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:feedUrl parameters:params];
             
             NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
             
             [request setAccount:[twitterAccounts lastObject]];
             
             [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 if (responseData && urlResponse.statusCode == 200)
                 {
                     NSError *err;
                     NSArray *feedDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
                     for (NSDictionary *data in feedDict)
                     {
                         Tweet *tweet = [Tweet initWithDict:data withManagedContext:self.managedContext];
                         NSLog(@"tweet parsing - %@ %@", tweet.text, tweet.composer.name);
                         NSError *error = nil;
                         [self.managedContext save:&error];
                     }
                     
                     NSLog(@"s %d", feedDict.count);
                 }
             
                 
                }];
             
         }
    }];
    
}

@end