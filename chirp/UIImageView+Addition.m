//
//  UIImageView+Addition.m
//  chirp
//
//  Created by Dushyant Bansal on 12/12/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "UIImageView+Addition.h"

@implementation UIImageView (Addition)

- (void)loadImageFromURI:(NSString *)imageUri
{
    NSURL *url = [NSURL URLWithString:imageUri];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [UIImage imageWithData:data];
    if (image)
    {
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        self.image = image;
    }
}

@end
