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


- (IBAction)postTweet:(UIBarButtonItem *)sender {
    NSDictionary *params = @{@"status": [self.tweetText text]};
    [self.tweetFetcher postTweetWithParams:params withCallBack:^(NSDictionary *tweetData){
        [Tweet tweetWithJSON:tweetData inManagedContext:self.managedContext];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancelTweet:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
