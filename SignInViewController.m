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

- (void)storeAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accessToken forKey:@"access_token"];
    [userDefaults synchronize];
}

- (NSString *)loadAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"access_token"];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self loadAccessToken])
        return;
    
    NSString *consumerKey = @"HdYpIQHu000GiSJ0SPGGw";
    NSString *secretKey = @"uBOLiEdqobCBfUATnDEmBGUhp6Kci6gJaqmtssrThY";
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:consumerKey andSecret:secretKey];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success){
//        [self presentViewController:loginController animated:YES completion:nil];
     NSLog(@"completed");
    }];
    
    [self presentViewController:loginController animated:YES completion:nil];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    NSString *uri = @"https://api.twitter.com/oauth/request_token";
//    NSString *callbackUri = @"https://api.twitter.com/oauth/authenticate";
//    
//    NSDictionary *params = @{@"oauth_callback": callbackUri, @"oauth_consumer_key": consumerKey};
//    
//    [manager POST:uri parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){} failure:^(AFHTTPRequestOperation *operation, NSError *error){}];
//    
//    
//    NSURL *url = [[NSURL alloc] initWithString:uri];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:request];
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
