//
//  UsersViewController.m
//  chirp
//
//  Created by Dushyant Bansal on 12/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "UsersViewController.h"
#import "Constants.h"
#import "User.h"
#import "UIImageView+Addition.h"
#import "UsersManager.h"

static NSString *const UserRowIdentifier = @"user row";

@interface UsersViewController ()
@property (strong, nonatomic) UsersManager *usersManager;
@end

@implementation UsersViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.usersManager fetchFollowersForUser:[self userScreenName] success:^(void) {}];
}

- (UsersManager *)usersManager {
  if (_usersManager == nil) {
    _usersManager = [[UsersManager alloc] initWithManagedContext:self.managedObjectContext];
  }
  return _usersManager;
}

- (NSString *)userScreenName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SignedInUserScreenNameKey];
}

- (void)initFetchedResultsControllerWithMOC:(NSManagedObjectContext *)managedContext {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
//  request.predicate = [NSPredicate predicateWithFormat:@"ANY self.friends.screenName == %@", [self userScreenName]];
  request.predicate = [NSPredicate predicateWithFormat:@"self IN %@", [[self.usersManager signedInUser] followers]];
  request.sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
  
  self.fetchedResultsController =
  [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                      managedObjectContext:managedContext
                                        sectionNameKeyPath:nil
                                                 cacheName:nil];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
  _managedObjectContext = managedObjectContext;
  [self initFetchedResultsControllerWithMOC:_managedObjectContext];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserRowIdentifier];
  
  User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [cell.imageView loadImageFromURI:user.profileImageUrl];
  cell.textLabel.text = user.screenName;
  cell.detailTextLabel.text = user.name;
  return cell;
}

@end