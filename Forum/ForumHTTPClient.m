//
//  ForumHTTPClient.m
//  Forum
//
//  Created by DI LIU on 8/8/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumHTTPClient.h"
#import "ForumInfo.h"
#import "ForumUser.h"
#import "NSString+MD5.h"
#import "ForumListItemStore.h"
#import "ForumDetailItemStore.h"
#import "ForumLoginViewController.h"
#import "ForumDetailTableViewController.h"
#import "ForumListTableViewController.h"
#import "ForumUserViewController.h"

#import "PostListResponseSerializer.h"
#import "PostDetailResponseSerializer.h"
#import "CodeOneResponseSerializer.h"
#import "CodeTwoResponseSerializer.h"
#import "RawResponseSerializer.h"
#import "ReplyToReplyResponseSerializer.h"
#import "UserInfoResponseSerializer.h"

#import <SVProgressHUD.h>
#import <SWRevealViewController.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking.h>

@interface ForumHTTPClient ()

@property (retain, nonatomic) NSString *loginHash;
@property (retain, nonatomic) NSString *formHash;
@property (retain, nonatomic) NSString *secHash;

@property (retain, nonatomic) NSArray *cookies;

@end

@implementation ForumHTTPClient

#pragma mark - Initialization

+ (ForumHTTPClient *)sharedClient
{
    static ForumHTTPClient *_sharedClient = nil;
    NSString *forumBaseURL = [[ForumInfo sharedInfo] baseURL];
    
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL: [NSURL URLWithString: forumBaseURL]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL: url];
    
    if ( self ) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.requestSerializer setValue: @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"
                      forHTTPHeaderField: @"User-Agent"];
        
        NSString *path = [self archivePath];
        NSDictionary *rootDic = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
        
        if ( rootDic ) {
            self.isLoggedin = [rootDic[@"status"] boolValue];
            self.cookies = rootDic[@"cookies"];
            for ( NSHTTPCookie *cookie in self.cookies ) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie: cookie];
            }
        }
        else {
            self.isLoggedin = NO;
        }
    }
    return self;
}

#pragma mark - Archiving

- (NSString *)archivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES);
    
    return [[documentDirectories firstObject] stringByAppendingPathComponent: @"dic.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self archivePath];
    self.cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *rootDic = @{ @"status": [NSNumber numberWithBool: self.isLoggedin],
                               @"cookies": self.cookies };
    
    return [NSKeyedArchiver archiveRootObject: rootDic
                                       toFile: path];
}

#pragma mark - POST methods

- (void)fetchVerificationCodeToImageView:(UIImageView *)imageView
{
    [SVProgressHUD showWithStatus: @"获取验证码中..." maskType: SVProgressHUDMaskTypeClear];
    self.responseSerializer = [CodeOneResponseSerializer serializer];
    NSDictionary *paramOne = @{ @"mod": @"logging",
                                @"action": @"login" };
    NSString *loginURL = [[ForumInfo sharedInfo] loginURL];
    NSString *codeURL = [[ForumInfo sharedInfo] codeURL];
    
    [self GET:loginURL parameters:paramOne success:^(NSURLSessionDataTask *task, id responseObject) {
        self.loginHash = responseObject[0];
        self.formHash = responseObject[1];
        self.secHash = responseObject[2];
        
        NSDictionary *paramTwo = @{ @"mod": @"seccode",
                                    @"action": @"update",
                                    @"idhash": self.secHash,
                                    @"inajax": @"1",
                                    @"ajaxtarget": [NSString stringWithFormat: @"seccode_%@", self.secHash] };
        
        self.responseSerializer = [CodeTwoResponseSerializer serializer];
        [self GET: codeURL parameters: paramTwo success: ^(NSURLSessionDataTask *task, id responseObject) {
            NSString *imgURL = responseObject;
            self.responseSerializer = [AFImageResponseSerializer serializer];
            [self.requestSerializer setValue: @"http://bbs.8080.net/member.php?mod=logging&action=login"
                          forHTTPHeaderField: @"Referer"];
            [self.requestSerializer setValue: @"bbs.8080.net"
                          forHTTPHeaderField: @"Host"];
            
            [self GET: imgURL parameters: nil success: ^(NSURLSessionDataTask *task, id responseObject) {
                
                [self.loginController showKeyboard];
                [SVProgressHUD dismiss];
                UIImage *codeImg = responseObject;
                imageView.image = codeImg;
                [self.requestSerializer setValue: nil
                              forHTTPHeaderField: @"Referer"];
                [self.requestSerializer setValue: nil
                              forHTTPHeaderField: @"Host"];
                self.responseSerializer = [AFHTTPResponseSerializer serializer];
            }failure:^(NSURLSessionDataTask *task, NSError *error) {
                [SVProgressHUD showErrorWithStatus: @"验证码获取失败"];
                NSLog(@"%@", error.localizedDescription);
            }];
            
        }failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus: @"验证码获取失败"];
            NSLog(@"%@", error.localizedDescription);
        }];
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"验证码获取失败"];
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)whetherIsLoggedIn
{
    NSString *baseURL = [ForumInfo sharedInfo].baseURL;
    NSString *loginURL = [NSString stringWithFormat: @"%@%@?mod=logging&action=login", baseURL, [ForumInfo sharedInfo].loginURL];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: loginURL]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    operation.responseSerializer = [RawResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawHTML = responseObject;
        NSRange loginRange = [rawHTML rangeOfString: @"login"];
        
        if ( loginRange.location != NSNotFound ) {
            self.isLoggedin = NO;
            [SVProgressHUD showErrorWithStatus: @"登录失效\n请重新登录"];
            SWRevealViewController *revealController = [self.listController revealViewController];
            ForumLoginViewController *loginViewController = [[ForumLoginViewController alloc] init];
            [revealController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            revealController.rearViewRevealWidth = [ForumInfo sharedInfo].loginWidth;
            revealController.rearViewRevealOverdraw = [ForumInfo sharedInfo].overdrawWidth;
            [revealController setRearViewController: loginViewController animated: YES];
            [revealController setFrontViewPosition: FrontViewPositionRight animated: YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"网络异常"];
    }];
    
    [operation start];
}

- (void)loginWithUsername:(NSString *)username withPassword:(NSString *)password andCode:(NSString *)code
{
    [SVProgressHUD showWithStatus: @"登录中..." maskType: SVProgressHUDMaskTypeClear];
    NSString *pswdMD5 = [password MD5String];
    NSString *loginURL = [[ForumInfo sharedInfo] loginURL];
    NSString *codeURL = [[ForumInfo sharedInfo] codeURL];
    
    NSDictionary *loginCodeVerifyParam = @{ @"mod": @"seccode",
                                            @"action": @"check",
                                            @"inajax": @"1",
                                            @"idhash": self.secHash,
                                            @"secverify": code };
    self.responseSerializer = [RawResponseSerializer serializer];
    
    [self GET: codeURL parameters: loginCodeVerifyParam success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = responseObject;
        NSRange successRange = [result rangeOfString: @"succeed"];
        
        // What happens if code verification failed
        if ( successRange.location == NSNotFound ) {
            [SVProgressHUD showErrorWithStatus: @"验证码错误"];
        }
        // What happens if it succeeded
        else {
            [self.requestSerializer setValue: @"application/x-www-form-urlencoded"
                          forHTTPHeaderField: @"Content-Type"];
            self.responseSerializer = [RawResponseSerializer serializer];
            
            NSDictionary *loginDic = @{ @"formhash": self.formHash,
                                        @"referer": @"http://bbs.8080.net/./",
                                        @"username": username,
                                        @"password": pswdMD5,
                                        @"questionid": @"0",
                                        @"answer": @"",
                                        @"sechash": self.secHash,
                                        @"seccodeverify": code,
                                        @"loginsubmit": @"true" };
            NSString *loginStepTwoURL = [NSString stringWithFormat: @"%@?mod=logging&action=login&loginsubmit=yes&loginhash=%@&inajax=1", loginURL, self.loginHash];
            
            [self POST: loginStepTwoURL parameters: loginDic success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSString *result = responseObject;
                NSRange successRange = [result rangeOfString: @"main_succeed"];
                if ( successRange.location == NSNotFound ) {
                    [SVProgressHUD showErrorWithStatus: @"登录失败"];
                }
                else {
                    [SVProgressHUD showSuccessWithStatus:  @"登陆成功"];
                    [self.listController.revealViewController setRearViewController: nil];
                    [self.listController pushSectionView];
                    self.loginController = nil;
                    self.isLoggedin = YES;
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog( @"%@", error.localizedDescription );
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog( @"%@", error.localizedDescription );
    }];
}

- (void)postReplyToReply:(NSString *)message
{
    if ( [message length] < 5 ) {
        [SVProgressHUD showErrorWithStatus: @"内容短于5字节"];
        return;
    }
    
    NSString *replyURL = [ForumInfo sharedInfo].replyURL;
    NSString *formhash = [ForumInfo sharedInfo].postFormhash;
    NSString *fid = [NSString stringWithFormat: @"%@", [ForumInfo sharedInfo].sectionID];
    NSString *tid = [NSString stringWithFormat: @"%@", [ForumInfo sharedInfo].postID];
    NSString *replyID = [NSString stringWithFormat: @"%@", [ForumInfo sharedInfo].replyID];
    [SVProgressHUD showWithStatus: @"发布中" maskType: SVProgressHUDMaskTypeClear];
    
    NSDictionary *replyDic = @{ @"mod": @"post",
                                @"action": @"reply",
                                @"fid": fid,
                                @"tid": tid,
                                @"repquote": replyID,
                                @"extra": @"page%3D1",
                                @"page": @"1",
                                @"infloat": @"yes",
                                @"handlekey": @"reply",
                                @"inajax": @"1",
                                @"ajaxtarget": @"fwin_content_reply" };
    
    self.responseSerializer = [ReplyToReplyResponseSerializer serializer];
    [self GET: replyURL parameters: replyDic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = responseObject;
        NSString *noticeauthor = [dic objectForKey: @"noticeauthor"];
        NSString *noticetrimstr = [dic objectForKey: @"noticetrimstr"];
        NSString *noticeauthormsg = [dic objectForKey: @"noticeauthormsg"];
        
        self.responseSerializer = [RawResponseSerializer serializer];
        NSString *postURL = [NSString stringWithFormat: @"%@?mod=post&infloat=yes&action=reply&fid=%@&extra=&tid=%@&replysubmit=yes&inajax=1", replyURL, fid, tid];
        NSDictionary *postDic = @{ @"formhash": formhash,
                                   @"handlekey": @"reply",
                                   @"noticeauthor": noticeauthor,
                                   @"noticetrimstr": noticetrimstr,
                                   @"noticeauthormsg": noticeauthormsg,
                                   @"usesig": @"1",
                                   @"reppid": replyID,
                                   @"reppost": replyID,
                                   @"subject": @"",
                                   @"message": message,
                                   @"replysubmit": @"true" };
        [self POST: postURL parameters: postDic success:^(NSURLSessionDataTask *task, id responseObject) {
            NSString *result = responseObject;
            NSRange successRange = [result rangeOfString: @"succeedhandle"];
            NSRange fastRange = [result rangeOfString: @"请稍候再发表"];
            NSRange sensitiveRange = [result rangeOfString: @"审核"];
            
            if ( successRange.location != NSNotFound ) {
                [SVProgressHUD showSuccessWithStatus: @"发布成功"];
                [self.detailController.navigationController.topViewController.view endEditing: YES];
                [self.detailController.navigationController popViewControllerAnimated: YES];
            }
            else if ( fastRange.location != NSNotFound ) {
                [SVProgressHUD showErrorWithStatus: @"发布失败\n\n请等待10秒"];
            }
            else if ( sensitiveRange.location != NSNotFound ) {
                [SVProgressHUD showSuccessWithStatus: @"发布成功\n\n回复待审核"];
                [self.detailController.navigationController.topViewController.view endEditing: YES];
                [self.detailController.navigationController popViewControllerAnimated: YES];
            }
            else {
                [SVProgressHUD showErrorWithStatus: @"发布失败"];
            }

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus: @"网络异常"];
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"网络异常"];
    }];
}

- (void)postReply:(NSString *)message
{
    if ( [message length] < 5 ) {
        [SVProgressHUD showErrorWithStatus: @"内容短于5字节"];
        return;
    }
    
    NSString *replyURL = [ForumInfo sharedInfo].replyURL;
    NSString *formhash = [ForumInfo sharedInfo].postFormhash;
    NSNumber *fid = [ForumInfo sharedInfo].sectionID;
    NSNumber *tid = [ForumInfo sharedInfo].postID;
    [SVProgressHUD showWithStatus: @"发布中" maskType: SVProgressHUDMaskTypeClear];
    
    NSString *postURL = [NSString stringWithFormat: @"%@?mod=post&action=reply&fid=%@&tid=%@&extra=page%%3D1&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1", replyURL, fid, tid];
    NSDictionary *postDic = @{ @"message": message,
                               @"formhash": formhash,
                               @"usesig": @"1",
                               @"subject": @"" };
    self.responseSerializer = [RawResponseSerializer serializer];

    [self POST: postURL parameters: postDic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = responseObject;
        NSRange successRange = [result rangeOfString: @"succeedhandle"];
        NSRange fastRange = [result rangeOfString: @"请稍候再发表"];
        NSRange sensitiveRange = [result rangeOfString: @"审核"];
        
        if ( successRange.location != NSNotFound ) {
            [SVProgressHUD showSuccessWithStatus: @"发布成功"];
            [self.detailController.navigationController.topViewController.view endEditing: YES];
            [self.detailController.navigationController popViewControllerAnimated: YES];
        }
        else if ( fastRange.location != NSNotFound ) {
            [SVProgressHUD showErrorWithStatus: @"发布失败\n\n请等待10秒"];
        }
        else if ( sensitiveRange.location != NSNotFound ) {
            [SVProgressHUD showErrorWithStatus: @"回复待审核"];
            [self.detailController.navigationController.topViewController.view endEditing: YES];
            [self.detailController.navigationController popViewControllerAnimated: YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus: @"发布失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"网络异常"];
    }];
}

#pragma mark - GET methods

- (void)fetchInfoForUser:(NSNumber *)uid
{
    [SVProgressHUD showWithStatus: @"获取用户信息中..." maskType: SVProgressHUDMaskTypeClear];
    self.responseSerializer = [UserInfoResponseSerializer serializer];
    NSString *userURL = [NSString stringWithFormat: @"?%@", uid];
    
    [self GET: userURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        ForumUser *user = responseObject;
        self.userController.nameLabel.text = user.name;
        self.userController.levelLabel.text = user.level;
        self.userController.postLabel.text = [NSString stringWithFormat: @"%li / %li", (long)user.numberOfPost, (long)user.numberOfReply];
        
        NSString *dateFormatString = @"yyyy-MM-dd";
        NSString *timeZoneName = @"Asian/Shanghai";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: dateFormatString];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: timeZoneName]];
        NSString *date = [dateFormatter stringFromDate: user.registerDate];
        
        self.userController.dateLabel.text = date;
        [self.listController pushUserView];
        [SVProgressHUD dismiss];
        
        // Lazy load the avatar image
        __weak UIImageView *avatarView = self.userController.avatarView;
        NSString *avatarURL = [NSString stringWithFormat: @"http://bbs.8080.net/uc_server/avatar.php?uid=%@&size=middle", uid];
        NSURLRequest *avatarRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: avatarURL]];
        [avatarView setImageWithURLRequest: avatarRequest
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus: @"网络异常"];
    }];
}

- (void)refreshListTableView:(UITableView *)tableView WithIndicator:(UIActivityIndicatorView *)indicator
{
    [self.operationQueue cancelAllOperations];
    
    self.responseSerializer = [PostListResponseSerializer serializer];
    NSString *sectionURL = [[ForumInfo sharedInfo] sectionURL];
    [indicator startAnimating];
    
    [self GET: sectionURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[ForumListItemStore sharedStore] removeAllItems];
        [[ForumListItemStore sharedStore] copyAllItems: [responseObject objectForKey: @"array"]];
        [ForumInfo sharedInfo].listNextPageURL = [responseObject objectForKey: @"url"];
        if ( [[ForumInfo sharedInfo].listNextPageURL length] > 1 ) {
            [ForumInfo sharedInfo].listHasNextPage = YES;
        }
        [tableView reloadData];
        [indicator stopAnimating];
        [_listController.refreshControl endRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)refreshDetailTableView:(UITableView *)tableView WithIndicator:(UIActivityIndicatorView *)indicator
{
    [indicator startAnimating];
    NSString *postURL = [ForumInfo sharedInfo].postURL;
    
    self.responseSerializer = [PostDetailResponseSerializer serializer];
    [self GET: postURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[ForumDetailItemStore sharedStore] copyAllItems: [responseObject objectForKey: @"array"]];
        [ForumInfo sharedInfo].detailNextPageURL = [responseObject objectForKey: @"url"];
        [ForumInfo sharedInfo].postFormhash = [responseObject objectForKey: @"formhash"];
        
        if ( [[ForumInfo sharedInfo].detailNextPageURL length] > 1 ) {
            [ForumInfo sharedInfo].detailHasNextPage = YES;
        }
        [tableView reloadData];
        [indicator stopAnimating];
        [_detailController.refreshControl endRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)loadMoreItemsIntoListTableView:(UITableView *)tableView
{
    NSString *nextPageURL = [ForumInfo sharedInfo].listNextPageURL;
    
    self.responseSerializer = [PostListResponseSerializer serializer];
    [self GET: nextPageURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[ForumListItemStore sharedStore] copyAllItems: [responseObject objectForKey: @"array"]];
        [ForumInfo sharedInfo].listNextPageURL = [responseObject objectForKey: @"url"];
        [tableView reloadData];
    
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)loadMoreItemsIntoDetailTableView:(UITableView *)tableView
{
    NSString *nextPageURL = [ForumInfo sharedInfo].detailNextPageURL;
    
    self.responseSerializer = [PostDetailResponseSerializer serializer];
    [self GET: nextPageURL parameters: nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [[ForumDetailItemStore sharedStore] copyAllItems: [responseObject objectForKey: @"array"]];
        [ForumInfo sharedInfo].detailNextPageURL = [responseObject objectForKey: @"url"];
        [tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

@end
