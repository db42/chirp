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
#import "TweetVC.h"

@interface FeedCDVC ()

@end

@implementation FeedCDVC

- (void)setManagedContext:(NSManagedObjectContext *)managedContext
{
    _managedContext = managedContext;
    
    [self loadFetchedResultController];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setTweet"])
    {
        id destination = [segue destinationViewController];
        if ([destination respondsToSelector:@selector(setTweet:)])
        {
            Tweet *tweet = [self.resultController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
            [destination performSelector:@selector(setTweet:) withObject:tweet];
        }
        
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = [self.resultController objectAtIndexPath:indexPath];
    NSString *text = tweet.text;
    
    CGSize maxSize = CGSizeMake(206.0f, MAXFLOAT);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]}];
    
    
    CGRect rect = [attributedText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGSize size = rect.size;
//    NSLog(@"%@ %f", indexPath, size.height);
    return ceil(size.height) + 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet row"];
    
    
    Tweet *tweet = [self.resultController objectAtIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:tweet.composer.profileImageUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    if (image)
    {
        cell.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        cell.imageView.image = image;
    }
    cell.textLabel.text = tweet.composer.name;
    cell.detailTextLabel.text = tweet.text;
    
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)loadMoreRows
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentHeight = scrollView.contentSize.height;
    
    CGFloat yOffset = scrollView.contentOffset.y;
    CGFloat inset = scrollView.contentInset.bottom;
    CGFloat scrollHeight = scrollView.bounds.size.height;
    
    CGFloat scrolledContentHeight = yOffset + scrollHeight - inset;
    
    CGFloat reloadDistance = 10;
    if (scrolledContentHeight > contentHeight + reloadDistance)
    {
        [self loadMoreRows];
    }
}

@end
