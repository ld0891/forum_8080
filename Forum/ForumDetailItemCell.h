//
//  ForumDetailItemCell.h
//  Forum
//
//  Created by DI LIU on 8/4/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ForumDetailItem;

@interface ForumDetailItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *posterLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VerticalSpaceBetweenQuoteAndContent;

- (void)setCollectionViewDataSourceAndDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)item index: (NSInteger)index;

@end
