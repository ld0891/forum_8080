//
//  ForumListTableViewController.h
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

@class ForumSectionViewController;

#import <UIKit/UIKit.h>
#import <SWRevealViewController.h>

@interface ForumListTableViewController : UITableViewController <SWRevealViewControllerDelegate>

@property (nonatomic, retain) ForumSectionViewController *sectionController;

- (void)refreshList;
- (void)pushSectionView;
- (void)pushLoginView;
- (void)pushUserView;

@end
