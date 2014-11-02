//
//  ForumLoginViewController.m
//  Forum
//
//  Created by DI LIU on 8/11/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumLoginViewController.h"
#import "ForumSectionViewController.h"
#import "ForumInfo.h"
#import "NextTextField.h"

#import "ForumHTTPClient.h"
#import <AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CodeOneResponseSerializer.h"
#import "CodeTwoResponseSerializer.h"
#import "RawResponseSerializer.h"
#import "NSString+MD5.h"

#import <SWRevealViewController.h>
#import <SVProgressHUD.h>
#import <OnePasswordExtension.h>

static NSString * const loginURL = @"member.php";
static NSString * const codeURL = @"misc.php";

@interface ForumLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pswdField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UIImageView *codeView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *onePasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pswdLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) ForumHTTPClient *client;
@property (retain, nonatomic) NSString *loginHash;
@property (retain, nonatomic) NSString *formHash;
@property (retain, nonatomic) NSString *secHash;

@end

@implementation ForumLoginViewController

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing: YES];
}

- (IBAction)findLoginFrom1Password:(id)sender {
    
    if ( ![[OnePasswordExtension sharedExtension] isAppExtensionAvailable] ) {
        [SVProgressHUD showErrorWithStatus: @"未安装1Password"];
        return;
    }
    
    [self.view endEditing: YES];
    __weak typeof (self) miniMe = self;
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"http://8080.net"
                                                forViewController:self
                                                           sender:sender
                                                       completion:^(NSDictionary *loginDict, NSError *error) {
        if (!loginDict) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        __strong typeof(self) strongMe = miniMe;
        strongMe.nameField.text = loginDict[AppExtensionUsernameKey];
        strongMe.pswdField.text = loginDict[AppExtensionPasswordKey];
        [strongMe.codeField becomeFirstResponder];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)login:(id)sender
{
    NSString *username = self.nameField.text;
    NSString *password = self.pswdField.text;
    NSString *code = self.codeField.text;
    
    [self.client loginWithUsername: username
                      withPassword: password
                           andCode: code];
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    
    BOOL didResign = [textField resignFirstResponder];
    
    if ( !didResign ) {
        return NO;
    }
    
    if ( [(NextTextField *)textField nextField] != nil ) {
        [[(NextTextField *)textField nextField] becomeFirstResponder];
    }
    else {
        [self login: nil];
    }
    
    return YES;
    
}


- (void)showKeyboard
{
    [self.nameField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.client = [ForumHTTPClient sharedClient];
    self.client.loginController = self;
    
    // Set 1Password Button hidden if no 1Password app is available
    // Then expand the original login button
    // [self.onePasswordButton setHidden:![[OnePasswordExtension sharedExtension] isAppExtensionAvailable]];
    
    // Add click event on code image
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector( codeTapped )];
    singleTap.numberOfTapsRequired = 1;
    self.codeView.userInteractionEnabled = YES;
    [self.codeView addGestureRecognizer: singleTap];
    
    // Set up properties of UI elements
    self.navigationItem.title = @"社区登陆";
    self.navigationController.navigationBar.barTintColor = [ForumInfo sharedInfo].navBgColor;
    self.client = [ForumHTTPClient sharedClient];
    self.client.loginController = self;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.pswdField.returnKeyType = UIReturnKeyDone;
    self.codeField.returnKeyType = UIReturnKeyDone;
    self.pswdField.secureTextEntry = YES;
    
    self.titleView.backgroundColor = [[ForumInfo sharedInfo] navBgColor];
    UIColor *backgroundColor = [[ForumInfo sharedInfo] bgColor];
    self.view.backgroundColor = backgroundColor;
    self.nameField.backgroundColor = backgroundColor;
    self.pswdField.backgroundColor = backgroundColor;
    self.codeField.backgroundColor = backgroundColor;
    
    UIColor *textColor = [[ForumInfo sharedInfo] textColor];
    self.nameLabel.textColor = textColor;
    self.pswdLabel.textColor = textColor;
    self.codeLabel.textColor = textColor;
    self.nameField.textColor = textColor;
    self.pswdField.textColor = textColor;
    self.codeField.textColor = textColor;
    self.titleLabel.textColor = textColor;
    
    self.loginButton.tintColor = [[ForumInfo sharedInfo] lightTextColor];
    self.loginButton.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    self.loginButton.layer.cornerRadius = 3.0f;
    self.loginButton.clipsToBounds = YES;
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, self.titleView.frame.size.height, self.titleView.frame.size.width, 0.5f);
    TopBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.titleView.layer addSublayer:TopBorder];
    
    // Fetch the verification code
    [self.client fetchVerificationCodeToImageView: self.codeView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)codeTapped
{
    [self.client fetchVerificationCodeToImageView: self.codeView];
}

@end
