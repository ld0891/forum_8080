//
//  ForumDetailTableViewController.m
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumDetailTableViewController.h"
#import "ForumInputViewController.h"
#import "ForumUserViewController.h"
#import "ForumDetailItem.h"
#import "ForumDetailItemStore.h"
#import "ForumDetailItemCell.h"
#import "ForumListItemCell.h"
#import "ForumInfo.h"
#import "ForumLoadingCell.h"
#import "ForumImgCell.h"

#import <AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PostDetailResponseSerializer.h"
#import "ForumHTTPClient.h"

#import <MWPhotoBrowser/MWPhoto.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <SWRevealViewController.h>

@interface ForumDetailTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) ForumHTTPClient *client;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end

@implementation ForumDetailTableViewController

#pragma mark - Initialization

- (instancetype)init
{
    self = [super initWithStyle: UITableViewStylePlain];
    
    if ( self ) {
    
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

#pragma mark - View configuration & refresh

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    for ( NSURLSessionDataTask *task in self.client.tasks ) {
        [task cancel];
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = [ForumInfo sharedInfo].sectionName;
    
    UIColor *buttonColor = [[ForumInfo sharedInfo] buttonColor];
    navItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @""
                                                                 style: UIBarButtonItemStylePlain
                                                                target: nil
                                                                action: nil];
    navItem.backBarButtonItem.tintColor = buttonColor;
    
    // Load the NIB files for custom cell
    UINib *cellNib = [UINib nibWithNibName: @"ForumDetailItemCell" bundle:nil];
    [self.tableView registerNib: cellNib forCellReuseIdentifier: @"ForumDetailItemCell"];
    UINib *loadingNib = [UINib nibWithNibName: @"ForumLoadingCell" bundle: nil];
    [self.tableView registerNib: loadingNib forCellReuseIdentifier: @"ForumLoadingCell"];
    
    UIColor *bgColor = [[ForumInfo sharedInfo] detailBgColor];
    self.tableView.backgroundColor = bgColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // AFNetworking to load content
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    self.activityIndicator.color = [ForumInfo sharedInfo].textColor;
    UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView: self.activityIndicator];
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCompose
                                                                                   target: self
                                                                                   action: @selector( pushInputView )];
    self.navigationItem.rightBarButtonItems = @[ composeButton, indicatorButton ];
    
    self.client = [ForumHTTPClient sharedClient];
    self.client.detailController = self;
    [self.client refreshDetailTableView: self.tableView WithIndicator: self.activityIndicator];
    
    // Get Swipe Gesture
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget: self
                                                 action: @selector( swipeBack )];
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.delaysTouchesBegan = YES;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer: swipeRecognizer];
}

- (void)swipeBack
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    // adjust the layout of the cells
    [self.view setNeedsLayout];
    
    // refresh view...
}

- (void)pushInputView
{
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = [items firstObject];
    [ForumInfo sharedInfo].replyID = item.replyID;
    
    ForumInputViewController *inputViewController = [[ForumInputViewController alloc] init];
    [self.navigationController pushViewController: inputViewController animated: YES];
}

- (void)refreshDetail
{
    [self.client refreshDetailTableView: self.tableView WithIndicator: self.activityIndicator];
}

- (void)avatarTapped: (UITapGestureRecognizer *)tapRecognizer
{
    NSUInteger tag = tapRecognizer.view.tag;
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[tag];
    
    ForumUserViewController *userController = self.client.userController;
    if ( userController == nil ) {
        userController = [[ForumUserViewController alloc] init];
        self.client.userController = userController;
    }
    
    [self.revealViewController setRearViewController: userController];
    
    [self.client fetchInfoForUser: [NSNumber numberWithInteger: item.posterID]];
}


#pragma mark - Collection view configuration

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[collectionView.tag];
    
    if ( item.hasImage ) {
        return [item.imgArray count];
    }
    else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ForumImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ForumImgCell"
                                                                   forIndexPath: indexPath];
    cell.userInteractionEnabled = NO;
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[collectionView.tag];
    NSString *imgURL = item.imgArray[indexPath.row];
    NSString *baseURL = [[ForumInfo sharedInfo] baseURL];
    NSString *completeImageURL = [baseURL stringByAppendingString: imgURL];
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: completeImageURL]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.layer.borderWidth = 1.0;
    cell.imageView.layer.borderColor = [[ForumInfo sharedInfo] darkBgColor].CGColor;
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.clipsToBounds = YES;
    
    [self.activityIndicator startAnimating];
    __weak UIImageView *imageView = cell.imageView;
    [cell.imageView setImageWithURLRequest: imgRequest
                          placeholderImage: nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       [UIView transitionWithView: imageView
                                                         duration: 0.3f
                                                          options: UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           imageView.image = image;
                                                       } completion:nil];
                                       
                                       MWPhoto *mwPhoto = [MWPhoto photoWithImage: image];
                                       [item addImg: mwPhoto toIndex: indexPath.row];
                                       
                                       if ( [item numberOfImagesLoaded] == [item.imgArray count]) {
                                           [self.activityIndicator stopAnimating];
                                       }
                                       cell.userInteractionEnabled = YES;
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog( @"%@", error.localizedDescription );
                                   }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[collectionView.tag];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate: item];
    
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    
    [browser setCurrentPhotoIndex: indexPath.row];
    [self.navigationController pushViewController: browser animated: YES];
}

#pragma mark - Table view configuration

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [ForumInfo sharedInfo].detailHasNextPage ) {
        return [[[ForumDetailItemStore sharedStore] allItems] count] + 1;
    }
    return [[[ForumDetailItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [ForumInfo sharedInfo].detailHasNextPage && indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection: 0] ) {
        ForumLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ForumLoadingCell"];
        [cell.activityIndicator startAnimating];
        return cell;
    }
    
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[indexPath.row];
    ForumDetailItemCell *cell = (ForumDetailItemCell *)[tableView dequeueReusableCellWithIdentifier: @"ForumDetailItemCell"
                                                                forIndexPath: indexPath];
    
    [self configureForumDetailCell: cell atIndexPath: indexPath];
    
    // Add Tap Gesture to Avatar Image
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector( avatarTapped: )];
    tapRecognizer.numberOfTouchesRequired = 1;
    [cell.avatarView addGestureRecognizer: tapRecognizer];
    cell.avatarView.userInteractionEnabled = YES;
    cell.avatarView.tag = indexPath.row;
    
    // Lazy load the avatar image
    __weak UIImageView *avatarView = cell.avatarView;
    NSURL *avatarURL = [NSURL URLWithString: item.posterAvatarURL];
    NSURLRequest *avatarRequest = [NSURLRequest requestWithURL: avatarURL];
    UIImage *placeHolder = [UIImage imageNamed: @"detailPlaceholder.jpg"];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *nextPageURL = [ForumInfo sharedInfo].detailNextPageURL;
    if ( [nextPageURL length] > 1 && indexPath.row + 1 == [tableView numberOfRowsInSection: 0]) {
        [self.client loadMoreItemsIntoDetailTableView: tableView];
    }
    else if ( [ForumInfo sharedInfo].detailHasNextPage && indexPath.row + 1 == [tableView numberOfRowsInSection: 0] ) {
        ForumLoadingCell *myCell = (ForumLoadingCell *)cell;
        [myCell.activityIndicator stopAnimating];
        myCell.loadingLabel.text = @"已到底部";
        [myCell.contentView setNeedsDisplay];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[indexPath.row];
    [ForumInfo sharedInfo].replyID = item.replyID;
    
    ForumInputViewController *inputViewController = [[ForumInputViewController alloc] init];
    [self.navigationController pushViewController: inputViewController animated: YES];
}

- (void)configureForumDetailCell:(ForumDetailItemCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[ForumDetailItemStore sharedStore] allItems];
    ForumDetailItem *item = items[indexPath.row];
    
    cell.posterLabel.text = item.posterName;
    cell.dateLabel.text = item.chineseDate;
    cell.levelLabel.text = [NSString stringWithFormat: @"%i楼", (int)indexPath.row + 1];
    
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString: item.postContent];
    NSParagraphStyle *style = [[ForumInfo sharedInfo] style];
    [attrContent addAttribute: NSParagraphStyleAttributeName
                      value: style
                      range: NSMakeRange(0, attrContent.length)];
    cell.contentLabel.attributedText = attrContent;
    
    NSMutableAttributedString *attrQuote = [[NSMutableAttributedString alloc] initWithString: item.quoteContent];
    [attrQuote addAttribute: NSParagraphStyleAttributeName
                      value: style
                      range: NSMakeRange(0, attrQuote.length)];
    cell.quoteLabel.attributedText = attrQuote;
    
    // Deal with images in post
    [cell setCollectionViewDataSourceAndDelegate: self index: indexPath.row];
    cell.imageCollectionView.backgroundColor = [[ForumInfo sharedInfo] detailBgColor];
}

#pragma mark Dynamic height for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [ForumInfo sharedInfo].detailHasNextPage && indexPath.row + 1 == [self tableView:tableView numberOfRowsInSection: 0] ) {
        return 44;
    }
    return [self heightForForumDetailItemCellAtIndexPath: indexPath] + 1;
}

- (CGFloat)heightForForumDetailItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    static ForumDetailItemCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier: @"ForumDetailItemCell"];
        if ( sizingCell == nil ) {
            sizingCell = [[ForumDetailItemCell alloc] init];
        }
    });
    [self configureForumDetailCell: sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell: sizingCell] + sizingCell.imageCollectionView.collectionViewLayout.collectionViewContentSize.height;
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(ForumDetailItemCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
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
