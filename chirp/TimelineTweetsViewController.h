//
//  DemoFeedCDVC.h
//  chirp
//
//  Created by Dushyant Bansal on 11/15/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "TweetsCoreDataViewController.h"
#import "FHSTwitterEngine.h"

@interface TimelineTweetsViewController : TweetsCoreDataViewController<FHSTwitterEngineAccessTokenDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedContext;

@end
