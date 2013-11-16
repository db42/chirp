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
    NSString *name = [data objectForKey:@"name"];
    request.predicate = [NSPredicate predicateWithFormat:@"id_str = %@", name];
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
        user.id_str = [data objectForKey:@"id_str"];
        user.screen_name = [data objectForKey:@"screen_name"];
    }
    return user;
}

@end
