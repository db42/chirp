//
//  User+Create.m
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "User+Create.h"

static NSString *const TWTUserName = @"name";
static NSString *const TWTUserId = @"id_str";
static NSString *const TWTUserScreenName = @"screen_name";
static NSString *const TWTUserProfileImageUrl = @"profile_image_url";
static NSString *const TWTUserProfileBackgroundImageUrl = @"profile_background_image_url";
static NSString *const TWTUserStatusesCount = @"statuses_count";
static NSString *const TWTUserFollowersCount = @"followers_count";
static NSString *const TWTUserFriendsCount = @"friends_count";

@implementation User (Create)

+ (id)userWithJSON:(NSDictionary *)data inManagedContext:(NSManagedObjectContext *)managedContext
{
    NSString *userId = [data objectForKey:TWTUserId];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", userId];
    request.sortDescriptors = nil;
    
    NSError *fetchError;
    NSArray *resultUsers = [managedContext executeFetchRequest:request error:&fetchError];
    
    User *user;
    if (fetchError || !resultUsers)
    {
        NSLog(@"Error fetching from db - %@", fetchError);
    }
    else if (!resultUsers.count)
    {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedContext];
        user.name = [data objectForKey:TWTUserName];
        user.idString = [data objectForKey:TWTUserId];
        user.screenName = [data objectForKey:TWTUserScreenName];
        user.profileImageUrl = [data objectForKey:TWTUserProfileImageUrl];
        user.profileBackgroundImageUrl = [data objectForKey:TWTUserProfileBackgroundImageUrl];
        user.statusesCount = [data objectForKey:TWTUserStatusesCount];
        user.followersCount = [data objectForKey:TWTUserFollowersCount];
        user.friendsCount = [data objectForKey:TWTUserFriendsCount];
      user.friends = [[NSSet alloc] init];
      user.followers = [[NSSet alloc] init];
      
        NSError *saveError;
        bool success = [managedContext save:&saveError];
        if (!success)
        {
            NSLog(@"Error saving user in db - %@", saveError);
        }
    }
    else
    {
        user = [resultUsers lastObject];
    }
    return user;
}

@end
