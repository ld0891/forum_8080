//
//  ForumInputViewController.m
//  极速社区
//
//  Created by DI LIU on 9/6/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumInputViewController.h"
#import "ForumHTTPClient.h"
#import "ForumInfo.h"

@interface ForumInputViewController ()

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *replyMode;
@property (weak, nonatomic) ForumHTTPClient *client;

@end

@implementation ForumInputViewController

- (IBAction)replyButtonTapped:(id)sender
{
    NSString *postContent = self.textView.text;
    
    if ( self.replyMode.selectedSegmentIndex == 0 ) {
        [self.client postReply: postContent];
    }
    else {
        [self.client postReplyToReply: postContent];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self.textView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.client = [ForumHTTPClient sharedClient];
    
    UIColor *backgroundColor = [[ForumInfo sharedInfo] detailBgColor];
    UIColor *textColor = [[ForumInfo sharedInfo] textColor];
    self.view.backgroundColor = backgroundColor;
    self.textView.backgroundColor = backgroundColor;
    self.textView.textColor = textColor;
    
    self.textView.layer.borderColor = [[[ForumInfo sharedInfo] darkBgColor] CGColor];
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.cornerRadius = 3.0f;
    
    self.replyButton.tintColor = [[ForumInfo sharedInfo] lightTextColor];
    self.replyButton.backgroundColor = [[ForumInfo sharedInfo] darkBgColor];
    self.replyButton.layer.cornerRadius = 3.0f;
    self.replyButton.clipsToBounds = YES;
    self.replyMode.tintColor = [[ForumInfo sharedInfo] darkBgColor];
    
    self.navigationItem.title = @"回复帖子";

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget: self
                                             action: @selector( dismissKeyboard )];
    [self.view addGestureRecognizer: tapRecognizer];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget: self
                                                 action: @selector( swipeBack )];
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer: swipeRecognizer];
}

- (void)dismissKeyboard
{
    [self.view endEditing: YES];
}

- (void)swipeBack
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
