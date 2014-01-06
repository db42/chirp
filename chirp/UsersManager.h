//
//  UsersManager.h
//  chirp
//
//  Created by Dushyant Bansal on 12/21/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+Create.h"

@interface UsersManager : NSObject
- (User *)signedInUser;
- (id)initWithManagedContext:(NSManagedObjectContext *)managedContext;
- (void)fetchFollowersForUser:(NSString *)userScreenName success:(void(^)(void))success;
@end
