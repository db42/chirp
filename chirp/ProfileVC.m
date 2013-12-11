//
//  ProfileVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "ProfileVC.h"
#import "TwitterFetcher.h"
#import "User+Create.h"

@interface ProfileVC ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *nameView;
@property (weak, nonatomic) IBOutlet UITextView *screenNameView;

@property (weak, nonatomic) IBOutlet UIButton *tweetsCount;
@property (weak, nonatomic) IBOutlet UIButton *followersCountButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsCount;

@property (weak, nonatomic) IBOutlet UITableView *contentsTable;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@end

@implementation ProfileVC

- (TwitterFetcher *)tweetFetcher
{
    if (!_tweetFetcher) _tweetFetcher = [[TwitterFetcher alloc] init];
    return _tweetFetcher;
}

- (void)setUser:(User *)user
{
    _user = user;
    dispatch_async(dispatch_get_main_queue(), ^(void){
    [self refresh];
    });
}

- (void)refresh
{
    if (self.user)
    {
        NSURL *url = [NSURL URLWithString:self.user.profileBackgroundImageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            self.profileBackgroundImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            self.profileBackgroundImageView.image = image;
        }
        
        url = [NSURL URLWithString:self.user.profileImageUrl];
        data = [NSData dataWithContentsOfURL:url];
        
        image = [UIImage imageWithData:data];
        if (image)
        {
            self.profileImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            self.profileImageView.image = image;
        }
        
        self.nameView.text = self.user.name;
        self.screenNameView.text = self.user.screenName;
        
        //set buttons title
        [self.followersCountButton setTitle: [NSString stringWithFormat:@"%@ followers", self.user.followersCount] forState:UIControlStateNormal];
        
        [self.friendsCount setTitle: [NSString stringWithFormat:@"%@ friends", self.user.friendsCount] forState:UIControlStateNormal];
        
        [self.tweetsCount setTitle: [NSString stringWithFormat:@"%@ tweets", self.user.statusesCount] forState:UIControlStateNormal];
        
        
        //load tweets
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.userScreenName = @"dushyant_db";
    [self initUser];
}

- (void) initUser
{
        //fetch from db
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"screenName == %@", self.userScreenName];
        
        NSError *error;
        NSArray *resultUsers = [self.managedContext executeFetchRequest:request error:&error];
        
        if (resultUsers != nil && resultUsers.count == 1)
        {
            self.user = [resultUsers lastObject];
        }
        else
        {
            //fetch from twitterFetcher
            [self.tweetFetcher fetchUserWithScreenName:self.userScreenName withCallBackBlock:^(NSDictionary *tweetData){
                self.user = [User userWithJSON:tweetData inManagedContext:self.managedContext];
//                NSLog("%@", tweetData);
            }];
            
        }
}

@end
