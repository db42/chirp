//
//  Tweet+Create.h
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Create)

+ (id) initWithDict: (NSDictionary *) data withManagedContext:(NSManagedObjectContext *) managedContext;

@end
