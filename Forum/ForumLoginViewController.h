//
//  ForumLoginViewController.h
//  Forum
//
//  Created by DI LIU on 8/11/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

@class ForumListTableViewController;

#import <UIKit/UIKit.h>

@interface ForumLoginViewController : UIViewController

@property (weak, nonatomic) ForumListTableViewController *listController;

-(void) showKeyboard;

@end
