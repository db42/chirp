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
    NSString *tweetId = [data objectForKey:@"id_str"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"id_str = %@", tweetId];
    request.sortDescriptors = Nil;
    
    NSError *error;
    NSArray *tweetsArray = [managedContext executeFetchRequest:request error:&error];
    
    Tweet *tweet;
    //if error
    if (!tweetsArray || [tweetsArray count] > 1)
    {
        NSLog(@"error %@", error);
    }
    //not present in core data
    else if (![tweetsArray count])
    {
        //store in db
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:managedContext];
        
        tweet.idString = [data objectForKey:@"id_str"];
        tweet.text = [data objectForKey:@"text"];
        
        tweet.composer = [User initWithDict:[data objectForKey:@"user"] withManagedContext:managedContext];
        
        
        bool success = [managedContext save:&error];
        NSLog(@"save success %d", success);
    }
    //if present in core data
    else
    {
        tweet =  [tweetsArray lastObject];
    }
    return tweet;
}

@end
