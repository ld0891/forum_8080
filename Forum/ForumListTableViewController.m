//
//  ForumListTableViewController.m
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumLoginViewController.h"
#import "ForumSectionViewController.h"
#import "ForumListTableViewController.h"
#import "ForumDetailTableViewController.h"
#import "ForumUserViewController.h"
#import "ForumListItemStore.h"
#import "ForumDetailItemStore.h"
#import "ForumListItem.h"
#import "ForumListItemCell.h"
#import "ForumInfo.h"
#import "ForumLoadingCell.h"

#import <AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PostListResponseSerializer.h"
#import "ForumHTTPClient.h"

#import <SWRevealViewController.h>
#import <SVProgressHUD.h>

@interface ForumListTableViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) ForumHTTPClient *client;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end

@implementation ForumListTableViewController

#pragma mark - Initialization

- (instancetype)init
{
    self = [super initWithStyle: UITableViewStylePlain];
    
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

#pragma mark - View configuration & Refresh

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    // Judge whether to push login or section view
    if ( [ForumInfo sharedInfo].isFirstLoad ) {
        [ForumInfo sharedInfo].isFirstLoad = NO;
        if ( self.client.isLoggedin ) {
            [self pushSectionView];
            [self.client whetherIsLoggedIn];
        }
        else {
            [self pushLoginView];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    self.client = [ForumHTTPClient sharedClient];
    self.client.listController = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    SWRevealViewController *revealController = [self revealViewController];
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = [ForumInfo sharedInfo].sectionName;
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemBookmarks
                                                                                      target: revealController
                                                                                      action: @selector(revealToggle:)];
    UIColor *buttonColor = [[ForumInfo sharedInfo] buttonColor];
    revealButtonItem.tintColor = buttonColor;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    self.activityIndicator.color = [ForumInfo sharedInfo].textColor;
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView: self.activityIndicator];
    self.navigationItem.rightBarButtonItem = bbi;
    
    // Load the NIB file for custom ForumListItemCell
    UINib *listNib = [UINib nibWithNibName: @"ForumListItemCell" bundle: nil];
    [self.tableView registerNib: listNib forCellReuseIdentifier: @"ForumListItemCell"];
    UINib *loadingNib = [UINib nibWithNibName: @"ForumLoadingCell" bundle: nil];
    [self.tableView registerNib: loadingNib forCellReuseIdentifier: @"ForumLoadingCell"];
    
    // Set the background color
    UIColor *backgroundColor = [[ForumInfo sharedInfo] bgColor];
    self.tableView.backgroundColor = backgroundColor;
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Get refresh control feature
    UIRefreshControl *listRefresh = [[UIRefreshControl alloc] init];
    [listRefresh addTarget:self action:@selector(refreshList) forControlEvents: UIControlEventValueChanged];
    listRefresh.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    listRefresh.tintColor = [[ForumInfo sharedInfo] lightTextColor];
    NSDictionary *attrsDic = @{ NSForegroundColorAttributeName : [[ForumInfo sharedInfo] lightTextColor],
                                NSFontAttributeName : [UIFont preferredFontForTextStyle: @"UIFontTextStyleCaption1"] };
    NSAttributedString *refreshString = [[NSAttributedString alloc] initWithString: @"更新中"
                                                                        attributes: attrsDic];
    listRefresh.attributedTitle = refreshString;
    self.refreshControl = listRefresh;
        
    // Config the reveal feature
    [revealController tapGestureRecognizer];
    UIGestureRecognizer * panRecognizer = [revealController panGestureRecognizer];
    [self.view addGestureRecognizer: panRecognizer];
    
    revealController.rearViewRevealWidth = [[ForumInfo sharedInfo] loginWidth];
    revealController.rearViewRevealOverdraw = [[ForumInfo sharedInfo] overdrawWidth];
    
    // Set HUD color
    [SVProgressHUD setForegroundColor: [[ForumInfo sharedInfo] bgColor]];
    [SVProgressHUD setBackgroundColor: [[ForumInfo sharedInfo] textColor]];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    // adjust the layout of the cells
    [self.view setNeedsLayout];
    
    // refresh view...
}

- (void)pushSectionView
{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    
    revealController.rearViewRevealWidth = [[ForumInfo sharedInfo] sectionWidth];
    revealController.rearViewRevealOverdraw = [[ForumInfo sharedInfo] overdrawWidth];
    
    ForumSectionViewController *sectionController = self.sectionController;
    
    if ( sectionController == nil ) {
        sectionController = [[ForumSectionViewController alloc] init];
        sectionController.listController = self;
        self.sectionController = sectionController;
    }
    
    [revealController setRearViewController: sectionController];
    [revealController setFrontViewPosition: FrontViewPositionRight animated: YES];
}

- (void)pushLoginView
{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController setFrontViewPosition: FrontViewPositionLeft animated: YES];
    
    revealController.rearViewRevealWidth = [[ForumInfo sharedInfo] loginWidth];
    revealController.rearViewRevealOverdraw = [[ForumInfo sharedInfo] overdrawWidth];
    ForumLoginViewController *loginController = [[ForumLoginViewController alloc] init];
    loginController.listController = self;
    
    [revealController setRearViewController: loginController];
    [revealController setFrontViewPosition: FrontViewPositionRight animated: YES];
}

- (void)pushUserView
{
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setFrontViewPosition: FrontViewPositionRight animated: YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [[ForumInfo sharedInfo].listNextPageURL length] > 1 && indexPath.row + 1 == [tableView numberOfRowsInSection: 0] ) {
        NSString *nextPageURL = [ForumInfo sharedInfo].listNextPageURL;
        if ( [ForumInfo sharedInfo].listHasNextPage && [nextPageURL length] > 1 ) {
            [self.client loadMoreItemsIntoListTableView: tableView];
        }
        else if ( [ForumInfo sharedInfo].listHasNextPage ) {
            ForumLoadingCell *myCell = (ForumLoadingCell *)cell;
            [myCell.activityIndicator stopAnimating];
            myCell.loadingLabel.text = @"已到底部";
            myCell.loadingLabel.textColor = [[ForumInfo sharedInfo] textColor];
            [myCell.contentView setNeedsDisplay];
        }
    }
}

- (void)refreshList
{
    self.navigationItem.title = [ForumInfo sharedInfo].sectionName;
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    [self.tableView setContentOffset:CGPointMake(0, -64) animated:NO];
    
    [self.client refreshListTableView: self.tableView WithIndicator: self.activityIndicator];
}

- (void)avatarTapped: (UITapGestureRecognizer *)tapRecognizer
{
    NSUInteger tag = tapRecognizer.view.tag;
    NSArray *items = [[ForumListItemStore sharedStore] allItems];
    ForumListItem *item = items[tag];
    
    ForumUserViewController *userController = self.client.userController;
    if ( userController == nil ) {
        userController = [[ForumUserViewController alloc] init];
        self.client.userController = userController;
    }
    
    [self.revealViewController setRearViewController: userController];
    
    [self.client fetchInfoForUser: item.uid];
}

#pragma mark - Table view configuration

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( [ForumInfo sharedInfo].listHasNextPage ) {
        return [[[ForumListItemStore sharedStore] allItems] count] + 1;
    }
    return [[[ForumListItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [ForumInfo sharedInfo].listHasNextPage && indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection: 0] ) {
        ForumLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ForumLoadingCell"];
        [cell.activityIndicator startAnimating];
        
        return cell;
    }
    
    NSArray *theItems = [[ForumListItemStore sharedStore] allItems];
    ForumListItem *item = theItems[indexPath.row];
    
    ForumListItemCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ForumListItemCell"
                                                            forIndexPath: indexPath];
    
    // Configure the cell...
    [self configureForumListItemCell: cell atIndexPath: indexPath];
    
    cell.avatarView.tag = indexPath.row;
    
    // Add Tap Gesture to Avatar Image
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector( avatarTapped: )];
    tapRecognizer.numberOfTouchesRequired = 1;
    [cell.avatarView addGestureRecognizer: tapRecognizer];
    cell.avatarView.userInteractionEnabled = YES;
    
    // Lazy load the avatar image
    __weak UIImageView *avatarView = cell.avatarView;
    NSString *baseURL = [[ForumInfo sharedInfo] baseURL];
    NSURL *avatarURL = [NSURL URLWithString: [baseURL stringByAppendingString: item.posterAvatarURL]];
    UIImage *placeHolder = [UIImage imageNamed: @"listPlaceholder.jpg"];
    NSURLRequest *avatarRequest = [NSURLRequest requestWithURL: avatarURL];
    [cell.avatarView setImageWithURLRequest: avatarRequest
                           placeholderImage: placeHolder
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
    
    return cell;
}

- (void)configureForumListItemCell:(ForumListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *theItems = [[ForumListItemStore sharedStore] allItems];
    ForumListItem *item = theItems[indexPath.row];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString: item.title];
    [attrTitle addAttribute: NSParagraphStyleAttributeName
                      value: [[ForumInfo sharedInfo] style]
                      range: NSMakeRange(0, attrTitle.length)];
    cell.titleLabel.attributedText = attrTitle;
    
    cell.posterLabel.text = item.posterName;
    NSString *viewString = [NSString stringWithFormat: @"%i / %i", (int)item.numOfReply, (int)item.numOfView];
    cell.viewLabel.text = viewString;
    cell.dateLabel.text = item.chineseDate;
    
    UIColor *textColor = [[ForumInfo sharedInfo] textColor];
    UIColor *ltGrayColor = [UIColor lightGrayColor];
    cell.titleLabel.textColor = item.isRead ? ltGrayColor : textColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath: indexPath animated: NO];
    [ForumInfo sharedInfo].detailHasNextPage = NO;
    [ForumInfo sharedInfo].detailNextPageURL = @"";
    for ( NSURLSessionDataTask *task in self.client.tasks ) {
        [task cancel];
    }
    [[ForumDetailItemStore sharedStore] removeAllItems];
    
    ForumListItemCell *cell = (ForumListItemCell *)[tableView cellForRowAtIndexPath: indexPath];
    
    NSArray *theItems = [[ForumListItemStore sharedStore] allItems];
    ForumListItem *item = theItems[indexPath.row];
    item.isRead = YES;
    cell.titleLabel.textColor = [UIColor lightGrayColor];
    [cell.titleLabel setNeedsDisplay];
    
    ForumInfo *info = [ForumInfo sharedInfo];
    info.postURL = item.postDetailURL;
    info.postName = item.title;
    info.postID = item.tid;
    
    ForumDetailTableViewController *detailTableViewController = [[ForumDetailTableViewController alloc] init];
        
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @""
                                                                             style: UIBarButtonItemStylePlain
                                                                            target: nil
                                                                            action: nil] ;
    [self.navigationController pushViewController: detailTableViewController animated: YES];
}


#pragma mark Dynamic height for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [ForumInfo sharedInfo].listHasNextPage && indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection: 0] ) {
        return 44;
    }
    
    else {
        return [self heightForForumListCellAtIndexPath: indexPath];
    }
}

- (CGFloat)heightForForumListCellAtIndexPath:(NSIndexPath *)indexPath
{
    static ForumListItemCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier: @"ForumListItemCell"];});
    [self configureForumListItemCell: sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell: sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if ( position == FrontViewPositionLeft ) {
        [revealController setRearViewController: self.sectionController];
    }
}

/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( self.revealViewController.frontViewPosition == FrontViewPositionRight ) {
        return YES;
    }
    return NO;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

@end
