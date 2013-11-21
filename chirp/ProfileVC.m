//
//  ProfileVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Create.h"
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

- (void) initUser
{
        //fetch from db
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"screen_name == %@", self.userScreenName];
        
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
                self.user = [User initWithDict:tweetData withManagedContext:self.managedContext];
//                NSLog("%@", tweetData);
            }];
            
        }
}
- (void)setUser:(User *)user
{
    _user = user;
    dispatch_async(dispatch_get_main_queue(), ^(void){
    [self refresh];
    });
}

- (void)setUserScreenName:(NSString *)userScreenName
{
    _userScreenName = userScreenName;
    [self initUser];
}

- (void)refresh
{
    if (self.user)
    {
        NSURL *url = [NSURL URLWithString:self.user.profile_background_image_url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *image = [UIImage imageWithData:data];
        if (image)
        {
            self.profileBackgroundImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            self.profileBackgroundImageView.image = image;
        }
        
        url = [NSURL URLWithString:self.user.profile_image_url];
        data = [NSData dataWithContentsOfURL:url];
        
        image = [UIImage imageWithData:data];
        if (image)
        {
            self.profileImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            self.profileImageView.image = image;
        }
        
        self.nameView.text = self.user.name;
        self.screenNameView.text = self.user.screen_name;
        
        self.followersCountButton.titleLabel.text = [NSString stringWithFormat:@"%@ tweets", self.user.followers_count];
        self.followersCountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.friendsCount.titleLabel.text = [NSString stringWithFormat:@"%@ friends", self.user.friends_count];
        self.friendsCount.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.tweetsCount.titleLabel.text = [NSString stringWithFormat:@"%@ friends", self.user.statuses_count];
        self.tweetsCount.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refresh];
    
//    self.tweetsCount setTitle:@"" forState:
    
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
