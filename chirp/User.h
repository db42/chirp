//
//  User.h
//  chirp
//
//  Created by Dushyant Bansal on 11/20/13.
//  Copyright (c) 2013 Dushyant Bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * id_str;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screen_name;
@property (nonatomic, retain) NSNumber * statuses_count;
@property (nonatomic, retain) NSNumber * friends_count;
@property (nonatomic, retain) NSNumber * followers_count;
@property (nonatomic, retain) NSString * profile_image_url;
@property (nonatomic, retain) NSString * profile_background_image_url;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
