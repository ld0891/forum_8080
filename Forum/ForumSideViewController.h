//
//  ForumSideViewController.h
//  Forum
//
//  Created by DI LIU on 8/13/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

@class ForumListTableViewController;

#import <UIKit/UIKit.h>

@interface ForumSideViewController : UIViewController

@property (nonatomic, weak) ForumListTableViewController *listController;

- (void)fetchInfoForUser: (NSNumber *)uid;

@end
