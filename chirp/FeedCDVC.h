//
//  FeedCDVC.h
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "CoreDataViewController.h"

@interface FeedCDVC : CoreDataViewController <UITableViewDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedContext;

@end
