//
//  ProfileVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "ProfileViewController.h"
#import "TwitterFetcher.h"
#import "User+Create.h"
#import "UIImageView+Addition.h"
#import "NetworkActivityIndicator.h"
#import "Constants.h"
#import "UsersViewController.h"


@interface ProfileViewController ()
@property (strong, nonatomic) NSString *userScreenName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *nameView;
@property (weak, nonatomic) IBOutlet UITextView *screenNameView;

@property (weak, nonatomic) IBOutlet UIButton *tweetsCount;
@property (weak, nonatomic) IBOutlet UIButton *followersCountButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsCount;

@property (weak, nonatomic) IBOutlet UITableView *contentsTable;
@property (strong, nonatomic) User *signedInUser;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@end

@implementation ProfileViewController

- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}

- (NSString *)userScreenName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SignedInUserScreenNameKey];
}

- (void)setUserScreenName:(NSString *)userScreenName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userScreenName forKey:SignedInUserScreenNameKey];
}

- (void)setSignedInUser:(User *)user
{
    _signedInUser = user;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self refresh];
    });
}

- (void)refresh
{
    if (self.signedInUser)
    {
        [self.profileImageView loadImageFromURI:self.signedInUser.profileImageUrl];
        [self.profileBackgroundImageView loadImageFromURI:self.signedInUser.profileBackgroundImageUrl];
        
        self.nameView.text = self.signedInUser.name;
        self.screenNameView.text = self.signedInUser.screenName;
        
        //set buttons title
        [self.followersCountButton setTitle: [NSString stringWithFormat:@"%@ followers", self.signedInUser.followersCount]
                                   forState:UIControlStateNormal];
        [self.friendsCount setTitle: [NSString stringWithFormat:@"%@ friends", self.signedInUser.friendsCount]
                           forState:UIControlStateNormal];
        [self.tweetsCount setTitle: [NSString stringWithFormat:@"%@ tweets", self.signedInUser.statusesCount]
                          forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSignedInUser];
}

- (void) loadSignedInUser
{
    if (self.userScreenName)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"screenName == %@", self.userScreenName];
        
        NSError *error;
        NSArray *resultUsers = [self.managedContext executeFetchRequest:request error:&error];
        
        if (resultUsers != nil && resultUsers.count == 1)
        {
            self.signedInUser = [resultUsers lastObject];
        }
    }
    else
    {
        [self.tweetFetcher fetchSignedInUserWithSuccessHandler:^(NSDictionary *tweetData)
         {
             self.userScreenName = [tweetData objectForKey:@"screen_name"];
             self.signedInUser = [User userWithJSON:tweetData inManagedContext:self.managedContext];
         }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"followersTable"]) {
    UsersViewController *destController = (UsersViewController *)segue.destinationViewController;
    destController.managedObjectContext = self.managedContext;
  }
}

@end
