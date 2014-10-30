//
//  ForumListItemCell.m
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumListItemCell.h"
#import "ForumInfo.h"

@implementation ForumListItemCell

- (void)awakeFromNib
{
    // Initialization code
    // Config the avatar style
    self.avatarView.layer.cornerRadius = 4.0;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.layer.borderColor = [[ForumInfo sharedInfo] darkBgColor].CGColor;
        
    UIColor *bgColor = [[ForumInfo sharedInfo] bgColor];
    self.backgroundColor = bgColor;
    
    
    // Remove cell separator line inset
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end

