//
//  ForumSectionViewController.m
//  Forum
//
//  Created by DI LIU on 8/13/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumListTableViewController.h"
#import "ForumSectionViewController.h"
#import "ForumHTTPClient.h"
#import "ForumInfo.h"
#import "ForumListItemStore.h"
#import "YIInnerShadowView.h"

#import <SWRevealViewController.h>
#import <SVProgressHUD.h>

@interface ForumSectionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) ForumHTTPClient *client;

@end

@implementation ForumSectionViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ForumInfo sharedInfo].listHasNextPage = NO;
    [ForumInfo sharedInfo].listNextPageURL = @"" ;
    for ( NSURLSessionDataTask *task in self.client.tasks ) {
        [task cancel];
    }
    
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
    return 33;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                   reuseIdentifier: @"UITableViewCell"];
    NSArray *items = [[ForumInfo sharedInfo] sectionNames];
    NSString *title = items[indexPath.row];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize: 17.0];
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
    
    UIColor *backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    self.tableView.backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.titleLabel.textColor = [[ForumInfo sharedInfo] lightTextColor];
    
    YIInnerShadowView* innerShadowView = [[YIInnerShadowView alloc] initWithFrame: self.tableView.frame];
    innerShadowView.shadowRadius = 3;
    innerShadowView.shadowMask = YIInnerShadowMaskTop;
    [self.view addSubview:innerShadowView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
