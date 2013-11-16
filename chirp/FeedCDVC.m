//
//  FeedCDVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "FeedCDVC.h"
#import "CoreData/CoreData.h"
#import "Tweet.h"
#import "User.h"

@interface FeedCDVC ()

@end

@implementation FeedCDVC

- (void)setManagedContext:(NSManagedObjectContext *)managedContext
{
    _managedContext = managedContext;
    
    [self loadFetchedResultController];
    
}

- (void) loadFetchedResultController
{
    //setup managedContext
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_str" ascending:false];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedContext sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet row"];
    
    
    Tweet *tweet = [self.resultController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = tweet.composer.name;
    cell.detailTextLabel.text = tweet.text;
    
    return cell;
}

@end
