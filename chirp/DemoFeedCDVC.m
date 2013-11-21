//
//  DemoFeedCDVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "DemoFeedCDVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet+Create.h"
#import "User+Create.h"
#import "TwitterFetcher.h"
#import "ProfileVC.h"

@interface DemoFeedCDVC ()
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshController;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) User *user;

@end

@implementation DemoFeedCDVC


- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}

- (IBAction)refreshView {
    [self.refreshController beginRefreshing];
    [self fetchAndLoadTweets];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self. managedContext)
    {
        [self setUpManagedContext];
        
        //load tweets
        [self refreshView];
    }
}

- (void) fetchAndLoadTweets
{
    [self.tweetFetcher fetchTweets:20 withCallBackBlock:^(NSArray *tweetsData) {
        for (NSDictionary *data in tweetsData)
        {
            Tweet *tweet = [Tweet initWithDict:data withManagedContext:self.managedContext];

            NSLog(@"tweet parsing - %@ %@ %@", tweet.id_str, tweet.text, tweet.composer.name);
            NSError *error = nil;
            [self.managedContext save:&error];
        }
        //on ui thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.refreshController endRefreshing];
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"setUserScreenName"])
    {
        id destController = [segue destinationViewController];
        if ([destController respondsToSelector:@selector(setUserScreenName:)])
        {
            [destController performSelector:@selector(setUserScreenName:) withObject:@"dushyant_db"];
            [destController performSelector:@selector(setManagedContext:) withObject:self.managedContext];
        }
    }
}

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
@end
