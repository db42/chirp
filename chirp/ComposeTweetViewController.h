//
//  ComposeTweetViewController.h
//  chirp
//
//  Created by Dushyant Bansal on 12/4/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ComposeTweetViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedContext;

@end
