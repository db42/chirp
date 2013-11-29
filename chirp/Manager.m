//
//  Manager.m
//  chirp
//
//  Created by Dushyant Bansal on 11/28/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import "Manager.h"

@implementation Manager


static Manager *sharedSingleton;
+ (Manager *)sharedInstance
{
    return sharedSingleton;
}


+ (void)initialize
{
    static BOOL initialized = FALSE;
    if (!initialized)
    {
        initialized = TRUE;
        sharedSingleton = [[Manager alloc] init];
    }
}

- (NSManagedObjectContext *)managedContext
{
    if (!_managedContext){
        NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        fileUrl = [fileUrl URLByAppendingPathComponent:@"demo doc"];
        UIManagedDocument *document= [[UIManagedDocument alloc] initWithFileURL:fileUrl];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]])
        {
            [document saveToURL:fileUrl
               forSaveOperation:UIDocumentSaveForCreating
              completionHandler:^(BOOL success){
                if (success)
                {
                    _managedContext = document.managedObjectContext;
                }
            }];
        }
        else if (document.documentState == UIDocumentStateClosed)
        {
            [document openWithCompletionHandler:^(BOOL success){
                if (success)
                {
                    _managedContext = document.managedObjectContext;
                }
            }];
        }
        else
        {
            _managedContext = document.managedObjectContext;
        }
        
    }
    return _managedContext;
}

@end
