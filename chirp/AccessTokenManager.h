//
//  AccessTokenManager.h
//  chirp
//
//  Created by Dushyant Bansal on 12/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSTwitterEngine.h"

@interface AccessTokenManager : NSObject<FHSTwitterEngineAccessTokenDelegate>

- (BOOL)isAuthTokenPresent;
@end
