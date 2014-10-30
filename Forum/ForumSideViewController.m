//
//  ForumSideViewController.m
//  Forum
//
//  Created by DI LIU on 8/13/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumListTableViewController.h"
#import "ForumSideViewController.h"
#import "ForumHTTPClient.h"
#import "ForumInfo.h"
#import "ForumListItemStore.h"
#import "ForumUserInfo.h"
#import "UserInfoResponseSerializer.h"

#import <SWRevealViewController.h>
#import <SVProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "YIInnerShadowView.h"

@interface ForumSideViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) ForumHTTPClient *client;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation ForumSideViewController

- (void)fetchInfoForUser: (NSNumber *)uid
{
    [SVProgressHUD showWithStatus: @"获取用户信息中..." maskType: SVProgressHUDMaskTypeClear];
    self.client.responseSerializer = [UserInfoResponseSerializer serializer];
    NSString *infoURL = [NSString stringWithFormat: @"?%@", uid];
    
    [self.client GET: infoURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        ForumUserInfo *userInfo = responseObject;
        
        self.nameLabel.text = userInfo.name;
        self.levelLabel.text = userInfo.level;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.dateLabel.text = [dateFormatter stringFromDate: userInfo.registerDate];
        
        [self.listController pushSectionView];
        
        NSString *avatarURL = [NSString stringWithFormat: @"http://bbs.8080.net/uc_server/avatar.php?uid=%@&size=middle", uid];
        NSURLRequest *avatarRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: avatarURL]];
        __weak UIImageView *avatarView = self.avatarView;
        
        [self.avatarView setImageWithURLRequest: avatarRequest
                               placeholderImage: nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            
                                            [UIView transitionWithView: avatarView
                                                              duration: 0.3f
                                                               options: UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{
                                                                avatarView.image = image;
                                                            } completion:nil];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            NSLog( @"%@", error.localizedDescription );
                                        }];
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"网络异常"];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ForumInfo sharedInfo].listHasNextPage = NO;
    [ForumInfo sharedInfo].listNextPageURL = @"" ;
    [self.client.operationQueue cancelAllOperations];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    
    NSArray *sectionNameArray = [[ForumInfo sharedInfo] sectionNames];
    NSDictionary *sectionDic = [[ForumInfo sharedInfo] sectionDic];
    
    NSString *sectionName = sectionNameArray[indexPath.row];
    
    NSNumber *sectionID = [sectionDic objectForKey: sectionName];
    NSString *sectionURL = [NSString stringWithFormat: @"forum-%i-1.html", (int)[sectionID integerValue]];
    
    ForumInfo *info = [ForumInfo sharedInfo];
    info.sectionName = sectionName;
    info.sectionID = sectionID;
    info.sectionURL = sectionURL;
    
    [self.listController refreshList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ForumInfo sharedInfo] sectionNames] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                   reuseIdentifier: @"UITableViewCell"];
    NSArray *items = [[ForumInfo sharedInfo] sectionNames];
    NSString *title = items[indexPath.row];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.textLabel.textColor = [[ForumInfo sharedInfo] lightTextColor];
    cell.textLabel.highlightedTextColor = [[ForumInfo sharedInfo] textColor];
    cell.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    return cell;
}

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
    
    self.client = [ForumHTTPClient sharedClient];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"版块列表";
    self.navigationController.navigationBar.barTintColor = [[ForumInfo sharedInfo] darkBgColor];
    
    UIColor *titleColor = [[ForumInfo sharedInfo] lightTextColor];
    NSDictionary *textAttributes = @{ NSForegroundColorAttributeName: titleColor};
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.tableView.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    
    UIColor *textColor = [ForumInfo sharedInfo].lightTextColor;
    self.nameLabel.textColor = textColor;
    self.levelLabel.textColor = textColor;
    self.dateLabel.textColor = textColor;
    
    self.avatarView.layer.cornerRadius = 4.0f;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.borderWidth = 2.0f;
    self.avatarView.layer.borderColor = [[ForumInfo sharedInfo] bgColor].CGColor;
    self.avatarView.backgroundColor = [[ForumInfo sharedInfo] bgColor];
    
    // Add shadow drop for section selector
    CGRect shadowFrame = self.tableView.frame;
    YIInnerShadowView *shadowView = [[YIInnerShadowView alloc] initWithFrame: shadowFrame];
    shadowView.shadowRadius = 6.0f;
    shadowView.shadowMask = YIInnerShadowMaskTop;
    [self.view addSubview: shadowView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
