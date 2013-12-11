//
//  UsersStore.h
//  chirp
//
//  Created by Dushyant Bansal on 12/11/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UsersStore : NSObject

- (User *) userWithScreenName: (NSString *)screenName;
- (void) fetchUserWithScreenName: (NSString *)screenName withCallBackBlock:(void (^)(NSDictionary * tweetsData))callBackBlock;
@end
