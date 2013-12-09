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
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", tweetId];
    request.sortDescriptors = nil;
    
    NSError *error;
    NSArray *tweetsFromDB = [managedContext executeFetchRequest:request error:&error];
    
    Tweet *tweet;
    //if error
    if (!tweetsFromDB || [tweetsFromDB count] > 1)
    {
        NSLog(@"error %@", error);
    }
    //not present in core data
    else if (![tweetsFromDB count])
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
        tweet =  [tweetsFromDB lastObject];
    }
    return tweet;
}

@end
