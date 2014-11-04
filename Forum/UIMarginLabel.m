//
//  UIMarginLabel.m
//  极速社区
//
//  Created by DI LIU on 9/3/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "UIMarginLabel.h"

@implementation UIMarginLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {3, 3, 3, 3};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
