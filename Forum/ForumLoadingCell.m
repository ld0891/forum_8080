//
//  ForumLoadingCell.m
//  极速社区
//
//  Created by DI LIU on 8/28/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumLoadingCell.h"
#import "ForumInfo.h"

@implementation ForumLoadingCell

- (void)awakeFromNib
{
    // Initialization code
    UIColor *color = [ForumInfo sharedInfo].textColor;
    self.textLabel.textColor = color;
    self.activityIndicator.color = color;
    
    self.backgroundColor = [[ForumInfo sharedInfo] bgColor];
    self.loadingLabel.textColor = [[ForumInfo sharedInfo] textColor];
    
    // Remove cell separator line inset
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
