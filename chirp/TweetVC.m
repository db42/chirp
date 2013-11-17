//
//  TweetVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/17/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetVC.h"
#import "User.h"

@interface TweetVC ()
@property (weak, nonatomic) IBOutlet UITextView *tweetComposerName;
@property (weak, nonatomic) IBOutlet UITextView *tweetComposerScreenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@end

@implementation TweetVC

-(void)viewWillAppear:(BOOL)animated
{
    self.tweetComposerName.text = self.tweet.composer.name;
    self.tweetComposerScreenName.text = self.tweet.composer.screen_name;
    self.tweetText.text = self.tweet.text;
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
