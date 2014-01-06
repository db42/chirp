//
//  UsersManager.m
//  chirp
//
//  Created by Dushyant Bansal on 12/21/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "UsersManager.h"
#import "TwitterFetcher.h"
#import "Constants.h"

@interface UsersManager()
@property (strong, nonatomic) TwitterFetcher *tweetFetcher;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;
@end

@implementation UsersManager

- (id)initWithManagedContext:(NSManagedObjectContext *)managedContext {
  self = [super init];
  if (self) {
    self.managedContext = managedContext;
  }
  return self;
}

- (TwitterFetcher *)tweetFetcher {
  if (!_tweetFetcher) {
    _tweetFetcher = [[TwitterFetcher alloc] init];
  }
  return _tweetFetcher;
}

- (NSString *)userScreenName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SignedInUserScreenNameKey];
}

- (User *)signedInUser {
  User *signedInUser = nil;
  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screenName == %@", self.userScreenName];
  request.predicate = predicate;
  
  NSError *error;
  NSArray *users = [self.managedContext executeFetchRequest:request error:&error];
  if (users == nil || error != nil) {
    NSLog(@"error fetching signed in user");
  }
  else {
    signedInUser = [users lastObject];
  }
  return signedInUser;
}

- (void)fetchFollowersForUser:(NSString *)userScreenName success:(void (^)(void))success {
  User *signedInUser = [self signedInUser];
  if (signedInUser == nil) {
    return;
  }
  
  NSDictionary *queryParams = @{@"cursor":@"-1", @"screen_name":userScreenName};
  [self.tweetFetcher fetchFollowersForUser:queryParams success:^(NSArray *usersData) {
    for (id userId in usersData) {
      [self.tweetFetcher fetchUserWithScreenName:nil withUserId:userId success:^(NSDictionary *userData) {
        [self.managedContext performBlock:^{
          User *user = [User userWithJSON:userData inManagedContext:self.managedContext];
          if (user.friends == nil) {
            user.friends = [NSSet setWithObject:signedInUser];
          }
          else {
            [user addFriendsObject:signedInUser];
          }
          NSError *saveError;
          bool success = [self.managedContext save:&saveError];
          if (!success) {
            NSLog(@"Error saving user in db - %@", saveError);
          }
        }];
      }];
    }
    success();
  }];
}

@end
