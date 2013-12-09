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
@property (weak, nonatomic) IBOutlet UIImageView *composerImage;
@property (weak, nonatomic) IBOutlet UITextView *tweetComposerScreenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@end

@implementation TweetVC

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
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
    
    NSURL *url = [NSURL URLWithString:self.tweet.composer.profileImageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    if (image)
    {
        self.composerImage.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.composerImage.image = image;
    }
	// Do any additional setup after loading the view.
    self.tweetComposerName.text = self.tweet.composer.name;
    self.tweetComposerScreenName.text = self.tweet.composer.screenName;
    self.tweetText.text = self.tweet.text;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
