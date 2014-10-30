//
//  ForumDetailItem.m
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumDetailItem.h"
#import <MWPhoto.h>

@interface ForumDetailItem ()

@property (nonatomic) NSMutableArray *privateImgArray;
@property (nonatomic) NSMutableDictionary *privateImageDic;

@end

@implementation ForumDetailItem

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [_privateImgArray count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    return [_privateImageDic objectForKey: [NSNumber numberWithInteger: index]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hasQuote = NO;
        self.hasImage = NO;
        self.privateImgArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)numberOfImagesLoaded
{
    return [_privateImageDic count];
}

- (void)addImgURL:(NSString *)imgURL
{
    if ( imgURL != nil && ![_privateImgArray containsObject: imgURL] ) {
        [_privateImgArray addObject: imgURL];
    }
}

- (NSArray *)imgArray
{
    return self.privateImgArray;
}

- (NSDictionary *)imageDic
{
    return self.privateImageDic;
}

- (void)addImg:(MWPhoto *)image toIndex:(NSInteger)index
{
    if ( !_privateImageDic )
    {
        _privateImageDic = [[NSMutableDictionary alloc] init];
        [_privateImageDic setObject: image forKey: [NSNumber numberWithInteger: index]];
    }
    else if ( [_privateImageDic objectForKey: [NSNumber numberWithInteger: index]] == nil ) {
        [_privateImageDic setObject: image forKey: [NSNumber numberWithInteger: index]];
    }
}

@end
