//
//  ForumListItem.h
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumListItem : NSObject

@property (nonatomic, retain) NSNumber *tid;
@property (nonatomic, retain) NSNumber *uid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *posterName;
@property (nonatomic, retain) NSString *posterAvatarURL;
@property (nonatomic, retain) NSDate *postDate;
@property (nonatomic, retain) NSString *chineseDate;
@property (nonatomic) NSInteger numOfReply;
@property (nonatomic) NSInteger numOfView;
@property (nonatomic, retain) NSString *postDetailURL;
@property (nonatomic, retain) UIColor *fontColor;
@property (nonatomic, assign) BOOL isRead;

@end
