//
//  TweetVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/17/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetViewController.h"
#import "User.h"
#import "UIImageView+Addition.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetComposerName;
@property (weak, nonatomic) IBOutlet UIImageView *composerImage;
@property (weak, nonatomic) IBOutlet UITextView *tweetComposerScreenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@end

@implementation TweetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.composerImage loadImageFromURI:self.tweet.composer.profileImageUrl];
    self.tweetComposerName.text = self.tweet.composer.name;
    self.tweetComposerScreenName.text = self.tweet.composer.screenName;
    self.tweetText.text = self.tweet.text;
}

@end
