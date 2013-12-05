//
//  SignInViewController.m
//  chirp
//
//  Created by Dushyant Bansal on 12/3/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "SignInViewController.h"
#import "AFNetworking.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SignInViewController

- (void)viewWillAppear:(BOOL)animated
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *uri = @"https://api.twitter.com/oauth/request_token";
    NSString *callbackUri = @"https://api.twitter.com/oauth/authenticate";
    NSString *consumerKey = @"HdYpIQHu000GiSJ0SPGGw";
    
    NSDictionary *params = @{@"oauth_callback": callbackUri, @"oauth_consumer_key": consumerKey};
    
    [manager POST:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){} failure:^(AFHTTPRequestOperation *operation, NSError *error){}];
    
    
    NSURL *url = [[NSURL alloc] initWithString:uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
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
