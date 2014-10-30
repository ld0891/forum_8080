//
//  ForumInfo.h
//  Forum
//
//  Created by DI LIU on 8/13/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ForumInfo : NSObject

@property (nonatomic, readonly) NSString *baseURL;
@property (nonatomic, readonly) NSArray *sectionNames;
@property (nonatomic, readonly) NSArray *sectionIDs;
@property (nonatomic, readonly) NSDictionary *sectionDic;

@property (nonatomic, readonly) UIColor *bgColor;
@property (nonatomic, readonly) UIColor *darkBgColor;
@property (nonatomic, readonly) UIColor *detailBgColor;
@property (nonatomic, readonly) UIColor *navBgColor;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIColor *lightTextColor;
@property (nonatomic, readonly) UIColor *buttonColor;
@property (nonatomic, readonly) NSParagraphStyle *style;

@property (nonatomic, readonly) NSString *loginURL;
@property (nonatomic, readonly) NSString *codeURL;
@property (nonatomic, readonly) NSString *replyURL;

@property (readonly) CGFloat loginWidth;
@property (readonly) CGFloat sectionWidth;
@property (readonly) CGFloat overdrawWidth;

@property (nonatomic, retain) NSString *sectionName;
@property (nonatomic, retain) NSNumber *sectionID;
@property (nonatomic, retain) NSString *sectionURL;

@property (nonatomic, retain) NSString *postName;
@property (nonatomic, retain) NSNumber *postID;
@property (nonatomic, retain) NSString *postURL;
@property (nonatomic, retain) NSString *postFormhash;

@property (nonatomic, retain) NSNumber *replyID;

@property (nonatomic, retain) NSString *listNextPageURL;
@property (nonatomic, retain) NSString *detailNextPageURL;
@property (assign) BOOL listHasNextPage;
@property (assign) BOOL detailHasNextPage;

@property (assign) BOOL isFirstLoad;

+ (instancetype)sharedInfo;

@end
