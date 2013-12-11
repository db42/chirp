//
//  NSURL+Addition.h
//  chirp
//
//  Created by Dushyant Bansal on 12/11/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Addition)
+ (NSURL *) URLWithString:(NSString *)string queryParams:(NSDictionary *)params;
@end
