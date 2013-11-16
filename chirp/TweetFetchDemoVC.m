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
//    [self fetchTweets];
}


@end