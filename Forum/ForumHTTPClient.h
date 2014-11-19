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
@class ForumHTTPClient;

@protocol ForumHTTPClientListDelegate

- (void)httpClient: (ForumHTTPClient *)client didReceiveListData: (NSDictionary *)listData;

@end

@interface ForumHTTPClient : AFHTTPSessionManager

@property (nonatomic, weak) ForumLoginViewController *loginController;
@property (nonatomic, weak) ForumListTableViewController *listController;
@property (nonatomic, weak) ForumDetailTableViewController *detailController;
@property (nonatomic, retain) ForumUserViewController *userController;

@property (assign) BOOL isLoggedin;
@property (nonatomic, weak) id <ForumHTTPClientListDelegate> listDelegate;

+ (ForumHTTPClient *)sharedClient;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)fetchVerificationCodeToImageView:(UIImageView *)imageView;
- (void)loginWithUsername: (NSString *)username
             withPassword: (NSString *)password
                  andCode: (NSString *)code;
- (NSString *)archivePath;
- (BOOL)saveChanges;
- (void)whetherIsLoggedIn;

- (void)refreshList;
- (void)refreshDetailTableView:(UITableView *)tableView WithIndicator:(UIActivityIndicatorView *)indicator;

- (void)loadMoreItemsIntoListTableView:(UITableView *)tableView;
- (void)loadMoreItemsIntoDetailTableView:(UITableView *)tableView;

- (void)postReply: (NSString *)message;
- (void)postReplyToReply: (NSString *)message;

- (void)fetchInfoForUser: (NSNumber *)uid;

@end