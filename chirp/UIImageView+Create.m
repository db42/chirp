//
//  UIImageView+Create.m
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "UIImageView+Create.h"

@implementation UIImageView (Create)

+ (UIImageView *)imageViewWithUrlString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    return [[UIImageView alloc] initWithImage:image];
}

@end
