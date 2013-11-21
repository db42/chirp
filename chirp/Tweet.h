//
//  Tweet.h
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * id_str;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) User *composer;

@end
