//
//  User+Create.h
//  chirp
//
//  Created by Dushyant Bansal on 11/14/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "User.h"

@interface User (Create)

+ (id) userWithJSON: (NSDictionary *) data inManagedContext:(NSManagedObjectContext *) managedContext;
@end
