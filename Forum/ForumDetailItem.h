//
//  ForumDetailItem.h
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

@class MWPhoto;

#import <Foundation/Foundation.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface ForumDetailItem : NSObject <MWPhotoBrowserDelegate>

@property (nonatomic, retain) NSNumber *replyID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *posterName;
@property (assign) NSInteger posterID;
@property (nonatomic, retain) NSString *posterAvatarURL;
@property (nonatomic, retain) NSDate *postDate;
@property (nonatomic, retain) NSString *chineseDate;
@property (nonatomic, retain) NSString *postContent;
@property (assign) BOOL hasQuote;
@property (nonatomic, retain) NSString *quoteContent;
@property (assign) BOOL hasImage;
@property (nonatomic, readonly) NSArray *imgArray;
@property (nonatomic, readonly) NSDictionary *imageDic;

- (void)addImgURL:(NSString *)imgURL;
- (void)addImg:(MWPhoto *)image toIndex:(NSInteger) index;
- (NSUInteger)numberOfImagesLoaded;

@end
