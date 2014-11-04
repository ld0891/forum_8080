//
//  ForumDetailItemCell.m
//  Forum
//
//  Created by DI LIU on 8/4/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumDetailItemCell.h"
#import "ForumDetailItem.h"
#import "ForumImgCell.h"
#import "ForumInfo.h"
#import "UIMarginLabel.h"

@implementation ForumDetailItemCell

- (void)awakeFromNib
{
    [self.imageCollectionView registerClass: [UICollectionViewCell class] forCellWithReuseIdentifier: @"UICollectionViewCell"];

    UINib *imgCellNib = [UINib nibWithNibName: @"ForumImgCell" bundle: nil];
    [self.imageCollectionView registerNib: imgCellNib forCellWithReuseIdentifier: @"ForumImgCell"];
    
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Config the avatar style
    self.avatarView.layer.cornerRadius = 4.0;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.layer.borderColor = [[ForumInfo sharedInfo] darkBgColor].CGColor;
    
    UIColor *textColor = [[ForumInfo sharedInfo] textColor];
    self.contentLabel.textColor = textColor;
    self.quoteLabel.backgroundColor = [[ForumInfo sharedInfo] bgColor];
    
    UIColor *bgColor = [[ForumInfo sharedInfo] detailBgColor];
    self.backgroundColor = bgColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setCollectionViewDataSourceAndDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)item index:(NSInteger)index
{
    self.imageCollectionView.dataSource = item;
    self.imageCollectionView.delegate = item;
    self.imageCollectionView.tag = index;
    
    [self.imageCollectionView reloadData];
}

@end
