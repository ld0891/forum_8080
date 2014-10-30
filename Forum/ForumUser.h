//
//  ForumUser.h
//  极速社区
//
//  Created by DI LIU on 9/11/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumUser : NSObject

@property (nonatomic, retain) NSNumber *uid;
@property (nonatomic, retain) NSString *name;
@property (assign) NSUInteger numberOfReply;
@property (assign) NSUInteger numberOfPost;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSDate *registerDate;

@end
