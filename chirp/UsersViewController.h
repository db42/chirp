//
//  UsersViewController.h
//  chirp
//
//  Created by Dushyant Bansal on 12/19/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "CoreDataViewController.h"

@interface UsersViewController : CoreDataViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
