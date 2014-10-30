//
//  ForumUserInfo.h
//  极速社区
//
//  Created by DI LIU on 9/9/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumUserInfo : NSObject

@property (nonatomic, retain) NSNumber *uid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSDate *registerDate;

- (instancetype)initWithUID: (NSNumber *)uid;

@end
