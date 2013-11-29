//
//  Manager.h
//  chirp
//
//  Created by Dushyant Bansal on 11/28/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manager : NSObject

+ (Manager *)sharedInstance;
@property (nonatomic, strong) NSManagedObjectContext *managedContext;
@end
