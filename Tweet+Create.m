//
//  Tweet+Create.m
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "Tweet+Create.h"
#import "User+Create.h"

@implementation Tweet (Create)

+ (id)initWithDict:(NSDictionary *)data withManagedContext:(NSManagedObjectContext *)managedContext
{
    NSString *id_str = [data objectForKey:@"id_str"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"id_str = %@", id_str];
    request.sortDescriptors = Nil;
    
    NSError *error;
    NSArray *tweetsArray = [managedContext executeFetchRequest:request error:&error];
    
    Tweet *tweet;
    //if error
    if (error || !tweetsArray)
    {
        NSLog(@"error %@", error);
    }
    //if present in core data
    else if (tweetsArray.count)
    {
        tweet =  [tweetsArray lastObject];
    }
    //not present in core data
    else
    {
        //store in db
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:managedContext];
        
        tweet.id_str = [data objectForKey:@"id_str"];
        tweet.text = [data objectForKey:@"text"];
        
        tweet.composer = [User initWithDict:data withManagedContext:managedContext];
    }
    return tweet;
}

@end
