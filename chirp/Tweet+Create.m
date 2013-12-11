//
//  Tweet+Create.m
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "Tweet+Create.h"
#import "User+Create.h"

static NSString *const TWTTweetId = @"id_str";
static NSString *const TWTTweetText = @"text";

@implementation Tweet (Create)

+ (id)tweetWithJSON:(NSDictionary *)data inManagedContext:(NSManagedObjectContext *)managedContext
{
    NSString *tweetId = [data objectForKey:TWTTweetId];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"idString = %@", tweetId];
    request.sortDescriptors = nil;
    
    NSError *fetchError;
    NSArray *tweetsFromDB = [managedContext executeFetchRequest:request error:&fetchError];
    
    Tweet *tweet;
    if (!tweetsFromDB || [tweetsFromDB count] > 1)
    {
        NSLog(@"Error fetching from db - %@", fetchError);
    }
    else if (![tweetsFromDB count])
    {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:managedContext];
        
        tweet.idString = [data objectForKey:TWTTweetId];
        tweet.text = [data objectForKey:TWTTweetText];
        tweet.composer = [User userWithJSON:[data objectForKey:@"user"] inManagedContext:managedContext];
        
        NSError *saveError;
        bool success = [managedContext save:&saveError];
        if (!success)
        {
            NSLog(@"Error saving tweet in db - %@", saveError);
        }
    }
    else
    {
        tweet =  [tweetsFromDB lastObject];
    }
    return tweet;
}

@end
