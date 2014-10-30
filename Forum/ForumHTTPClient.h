//
//  ForumHTTPClient.h
//  Forum
//
//  Created by DI LIU on 8/8/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@class ForumDetailTableViewController;
@class ForumLoginViewController;
@class ForumListTableViewController;
@class ForumUserViewController;

@interface ForumHTTPClient : AFHTTPSessionManager

@property (nonatomic, weak) ForumLoginViewController *loginController;
@property (nonatomic, weak) ForumListTableViewController *listController;
@property (nonatomic, weak) ForumDetailTableViewController *detailController;
@property (nonatomic, retain) ForumUserViewController *userController;

@property (assign) BOOL isLoggedin;

+ (ForumHTTPClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)fetchVerificationCodeToImageView:(UIImageView *)imageView;
- (void)loginWithUsername: (NSString *)username
             withPassword: (NSString *)password
                  andCode: (NSString *)code;
- (NSString *)archivePath;
- (BOOL)saveChanges;
- (void)whetherIsLoggedIn;

- (void)refreshListTableView:(UITableView *)tableView WithIndicator:(UIActivityIndicatorView *)indicator;
- (void)refreshDetailTableView:(UITableView *)tableView WithIndicator:(UIActivityIndicatorView *)indicator;

- (void)loadMoreItemsIntoListTableView:(UITableView *)tableView;
- (void)loadMoreItemsIntoDetailTableView:(UITableView *)tableView;

- (void)postReply: (NSString *)message;
- (void)postReplyToReply: (NSString *)message;

- (void)fetchInfoForUser: (NSNumber *)uid;

@end