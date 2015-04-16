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
    NSDictionary *defaultsDictionary = @{ @"SettingsShowMicrosoftAlliance": @YES,
                                          @"SettingsShowAndroidJoypark": @YES,
                                          @"SettingsShowAppleHome": @YES,
                                          @"SettingsShowPhotographerClub": @YES,
                                          @"SettingsShowBroadband3G": @YES,
                                          @"SettingsShowHardwareExpert": @YES,
                                          @"SettingsShowILoveMyHome": @YES,
                                          @"SettingsShowInvestment": @YES,
                                          @"SettingsShowAVLife": @YES,
                                          @"SettingsShowGameWorld": @YES,
                                          @"SettingsShowPhysicalTraining": @YES,
                                          @"SettingsShowSpeedAuto": @YES,
                                          @"SettingsShowFoodTour": @YES,
                                          @"SettingsShowCharity": @YES,
                                          @"SettingsShowDearBaby": @YES,
                                          @"SettingsShowDailyLife": @YES,
                                          @"SettingsShowComputerHardware": @YES,
                                          @"SettingsShowAccessoryPeripheral": @YES,
                                          @"SettingsShowDesktop": @YES,
                                          @"SettingsShowLaptop": @YES,
                                          @"SettingsShowTrendyGadget": @YES,
                                          @"SettingsShowMobileWorld": @YES,
                                          @"SettingsShowClothing": @YES,
                                          @"SettingsShowAutoService": @YES,
                                          @"SettingsShowGourmetHeaven": @YES,
                                          @"SettingsShowFleaMarket": @YES,
                                          @"SettingsShowGlobalShopping": @YES,
                                          @"SettingsShowEmployment": @YES,
                                          @"SettingsShowMiscGood": @YES,
                                          @"SettingsShowShopForRent": @YES,
                                          @"SettingsShowHomeService": @YES,
                                          @"SettingsShowForumAffair": @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultsDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
