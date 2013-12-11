//
//  ComposeTweetViewController.m
//  chirp
//
//  Created by Dushyant Bansal on 12/4/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import "TwitterFetcher.h"
#import "Tweet+Create.h"

@interface ComposeTweetViewController ()

@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@end

@implementation ComposeTweetViewController

- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher)
        _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}


- (IBAction)postTweet:(UIBarButtonItem *)sender
{
    NSString *tweet = [self.tweetText text];
    if ([tweet length])
    {
        NSDictionary *params = @{@"status": tweet};
        [self.tweetFetcher postTweetWithParams:params success:^(NSDictionary *tweetData)
         {
             [Tweet tweetWithJSON:tweetData inManagedContext:self.managedContext];
             [self dismissViewControllerAnimated:YES completion:nil];
         }];
    }
}

- (IBAction)cancelTweet:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
