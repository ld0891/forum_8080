//
//  ForumUserViewController.h
//  极速社区
//
//  Created by DI LIU on 9/11/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
