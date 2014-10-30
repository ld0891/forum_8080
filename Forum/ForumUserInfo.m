//
//  ForumUserInfo.m
//  极速社区
//
//  Created by DI LIU on 9/9/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumUserInfo.h"

@implementation ForumUserInfo

- (instancetype)initWithUID:(NSNumber *)uid
{
    self = [super init];
    
    if ( self ) {
        _uid = uid;
    }
    
    return self;
}

@end
