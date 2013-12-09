//
//  User+Create.m
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "User+Create.h"

@implementation User (Create)

+ (id)initWithDict:(NSDictionary *)data withManagedContext:(NSManagedObjectContext *)managedContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSString *userId = [data objectForKey:@"id_str"];
    request.predicate = [NSPredicate predicateWithFormat:@"id_str = %@", userId];
    request.sortDescriptors = nil;
    
    User *user;
    NSError *error;
    NSArray *resultUsers = [managedContext executeFetchRequest:request error:&error];
    
    if (error || !resultUsers)
    {
        NSLog(@"error %@", error);
    }
    else if (resultUsers.count)
    {
        user = [resultUsers lastObject];
    }
    else
    {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedContext];
        user.name = [data objectForKey:@"name"];
        user.idString = [data objectForKey:@"id_str"];
        user.screenName = [data objectForKey:@"screen_name"];
        user.profileImageUrl = [data objectForKey:@"profile_image_url"];
        user.profileBackgroundImageUrl = [data objectForKey:@"profile_background_image_url"];
        user.statusesCount = [data objectForKey:@"statuses_count"];
        user.followersCount = [data objectForKey:@"followers_count"];
        user.friendsCount = [data objectForKey:@"friends_count"];
        
        [managedContext save:&error];
    }
    return user;
}

@end
