//
//  AppDelegate.m
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "ForumLoginViewController.h"
#import "ForumSectionViewController.h"
#import "ForumListTableViewController.h"
#import "ForumDetailTableViewController.h"
#import "ForumUserViewController.h"
#import "ForumInfo.h"
#import "ForumHTTPClient.h"

#import <SWRevealViewController.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Deal with NSUserDefaults
    NSDictionary *defaultsDictionary = @{ @"微软同盟": @YES,
                                          @"安卓乐园": @YES,
                                          @"苹果之家": @YES,
                                          @"色友俱乐部": @YES,
                                          @"宽带3G": @YES,
                                          @"硬件高手": @YES,
                                          @"我爱我家": @YES,
                                          @"投资理财": @YES,
                                          @"影音人生": @YES,
                                          @"游戏世界": @YES,
                                          @"强身健体": @YES,
                                          @"极速汽车": @YES,
                                          @"美食旅游": @YES,
                                          @"古城大爱": @YES,
                                          @"亲亲宝贝": @YES,
                                          @"点滴生活": @YES,
                                          @"电脑散件": @YES,
                                          @"配件外设": @YES,
                                          @"整机风云": @YES,
                                          @"时尚本本": @YES,
                                          @"潮流数码": @YES,
                                          @"移动天下": @YES,
                                          @"服饰鞋帽": @YES,
                                          @"汽车服务": @YES,
                                          @"吃货天堂": @YES,
                                          @"跳蚤市场": @YES,
                                          @"海淘代购": @YES,
                                          @"人才招聘": @YES,
                                          @"杂货物品": @YES,
                                          @"旺铺租赁": @YES,
                                          @"家政服务": @YES,
                                          @"站务&招商": @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultsDictionary];
    
    // Deal with styling
    self.window.tintColor = [[ForumInfo sharedInfo] buttonColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [[ForumInfo sharedInfo] textColor]}];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    ForumListTableViewController *fltvc = [[ForumListTableViewController alloc] init];
    ForumLoginViewController *flvc = [[ForumLoginViewController alloc] init];
    ForumSectionViewController *fsvc = [[ForumSectionViewController alloc] init];
    flvc.listController = fltvc;
    fsvc.listController = fltvc;
    
    UINavigationController *frontController = [[UINavigationController alloc] initWithRootViewController: fltvc];
    
    UIColor *barColor = [[ForumInfo sharedInfo] navBgColor];
    frontController.navigationBar.barTintColor = barColor;
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController: nil
                                                                                      frontViewController: frontController];
    revealController.delegate = fltvc;
    self.viewController = revealController;
    self.window.rootViewController = self.viewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL success = [[ForumHTTPClient sharedClient] saveChanges];
    if ( success ) {
        NSLog( @"save success" );
    }
    else {
        NSLog( @"save failure" );
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
