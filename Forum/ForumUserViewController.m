//
//  ForumUserViewController.m
//  极速社区
//
//  Created by DI LIU on 9/11/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumUserViewController.h"
#import "ForumInfo.h"

@interface ForumUserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ForumUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *textColor = [[ForumInfo sharedInfo] lightTextColor];
    self.nameLabel.textColor = textColor;
    self.levelLabel.textColor = textColor;
    self.postLabel.textColor = textColor;
    self.dateLabel.textColor = textColor;
    self.titleLabel.textColor = textColor;
    
    self.view.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    
    self.avatarView.layer.cornerRadius = 4.0;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.borderWidth = 1.0;
    self.avatarView.layer.borderColor = [[ForumInfo sharedInfo] bgColor].CGColor;
    self.avatarView.backgroundColor = [[ForumInfo sharedInfo] bgColor];
    
    // Add a fake navigation separator
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, 0.5f)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
