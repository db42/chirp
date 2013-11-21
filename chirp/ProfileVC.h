//
//  ProfileVC.h
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface ProfileVC : UIViewController

@property (strong, nonatomic) NSString *userScreenName;
@property (strong, nonatomic) NSManagedObjectContext *managedContext;

@end
