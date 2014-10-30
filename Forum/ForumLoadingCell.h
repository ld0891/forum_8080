//
//  ForumLoadingCell.h
//  极速社区
//
//  Created by DI LIU on 8/28/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForumLoadingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;


@end
