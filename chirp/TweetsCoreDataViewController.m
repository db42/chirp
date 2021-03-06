//
//  FeedCDVC.m
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetsCoreDataViewController.h"
#import "CoreData/CoreData.h"
#import "Tweet.h"
#import "User.h"
#import "TweetViewController.h"
#import "UIImageView+Addition.h"

static NSString *const IndividualTweetVCSegueId = @"individualTweet";

@interface TweetsCoreDataViewController ()
@end

@implementation TweetsCoreDataViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:IndividualTweetVCSegueId])
    {
        id destination = [segue destinationViewController];
        if ([destination respondsToSelector:@selector(setTweet:)])
        {
            Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
            [destination performSelector:@selector(setTweet:) withObject:tweet];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *text = tweet.text;
    
    CGSize maxSize = CGSizeMake(206.0f, MAXFLOAT);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]}];
    
    CGRect rect = [attributedText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size = rect.size;
    return ceil(size.height) + 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet row"];
    
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.imageView loadImageFromURI:tweet.composer.profileImageUrl];
    cell.textLabel.text = tweet.composer.name;
    cell.detailTextLabel.text = tweet.text;
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)loadMoreRows
{
    NSAssert(NO, @"Subclasses need to implement this method");
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
