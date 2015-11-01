//
//  MZNewUserViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/29/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZNewUserViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NSString *BASE_URL_ = @"http://192.168.1.125:5000/";

@interface MZNewUserViewController ()

@property(strong, nonatomic) UIButton *signUpButton;
@property(strong, nonatomic) UITextField *usernameTextField;
@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UILabel *finePrint;

@end

@implementation MZNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];

    self.titleLabel = [UILabel newAutoLayoutView];
    [self.titleLabel setText: @"Welcome to milzi!"];
    self.titleLabel.textColor = UIColorFromRGB(0xF38630);//(0xC44D58);// self.view.tintColor;
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:32.0f];
    
    self.finePrint = [UILabel newAutoLayoutView];
    [self.finePrint setText: @"up to 20 characters"];
    self.finePrint.textColor = UIColorFromRGB(0xA7DBD8);//(0x4ECDC4);// self.view.tintColor;
    self.finePrint.textAlignment = NSTextAlignmentRight;
    self.finePrint.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    self.usernameTextField = [UITextField newAutoLayoutView];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Choose a username" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
    self.usernameTextField.attributedPlaceholder = str;
    self.usernameTextField.font = [UIFont systemFontOfSize:22.0f];
    self.usernameTextField.textColor = [UIColor whiteColor];
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.signUpButton = [UIButton newAutoLayoutView];
    [self.signUpButton setTitle:@"Sign up" forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
    
    [self.usernameTextField becomeFirstResponder];

    [self.view addSubview:self.finePrint];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.signUpButton];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)showErrorMessage:(NSString *)errorMessage
{
    self.finePrint.text = errorMessage;
}

- (BOOL)isAlphaNumeric:(NSString *)aString
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([aString rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

- (BOOL)isInputValid
{
    BOOL isValid = true;
    NSUInteger len = [self.usernameTextField.text length];
    if (len == 0)
    {
        isValid = NO;
        [self showErrorMessage:@"can't be empty"];
    }
    else if (len > 20)
    {
        isValid = NO;
        [self showErrorMessage: @"let's stick to 20 characters"];
    } else if (![self isAlphaNumeric:self.usernameTextField.text])
    {
        [self showErrorMessage:@"only letters and numbers"];
        isValid = NO;
    }
    return isValid;
}

- (void)signup
{
    if ([self isInputValid])
    {
        [self showErrorMessage:@"connecting..."];
        
        NSURL *signupURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@adduser",BASE_URL_]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:signupURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setHTTPMethod:@"POST"];
        NSString *params = [NSString stringWithFormat:@"name=%@", self.usernameTextField.text];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (error)
            {
                [self showErrorMessage:[error localizedDescription]];
            } else if ([responseBody isEqualToString:@"dup"])
            {
                [self showErrorMessage:@"username taken :("];
            } else if ([responseBody isEqualToString:@"fail"])
            {
                [self showErrorMessage:@"something wrong happened :( try again"];
            } else {
                [self showErrorMessage:@"thanks for flying milzi! enjoy"];
                NSUserDefaults *deviceCache = [NSUserDefaults standardUserDefaults];
                [deviceCache setBool:YES forKey:@"friend"];
                [deviceCache setObject:responseBody forKey:@"my_id"];
                [deviceCache setObject:self.usernameTextField.text forKey:@"my_name"];
                [deviceCache synchronize];
                [self.usernameTextField resignFirstResponder];

                //delay to let the user see the message
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    self.feedVC.tabBarController.tabBar.userInteractionEnabled = YES;
                    [self.feedVC.navigationController  dismissViewControllerAnimated:YES completion:nil];
                });
                
            }
           // NSLog(@"response: %@", responseBody);
        }];
        
        [postDataTask resume];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.usernameTextField.frame.size.height - 1 , self.usernameTextField.frame.size.width, 2.0f);
    bottomBorder.backgroundColor = UIColorFromRGB(0xF38630).CGColor;
    [self.usernameTextField.layer addSublayer:bottomBorder];
    
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    [self.usernameTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:floor(screenRect.height * 0.25)];
    [self.usernameTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:floor(screenRect.width * 0.10)];
    [self.usernameTextField autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:floor(screenRect.width * 0.10)];
    
    [self.finePrint autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.usernameTextField];
    [self.finePrint autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.usernameTextField withOffset:0];
    
    [self.signUpButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.finePrint withOffset:30];
    [self.signUpButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.usernameTextField];
}


@end
