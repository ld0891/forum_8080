//
//  ForumListItemCell.h
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumListItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *posterLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;

@end
