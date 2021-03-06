//
//  MZAddPollViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/27/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZAddPollViewController.h"

const NSUInteger MAX_CHAR_COUNT = 100;

@interface MZAddPollViewController ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *questionCharCounterLabel;
@property (nonatomic, strong) UIImageView *chosenImgView;
@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIButton *takeImageBtn, *selectImgBtn;
@property (nonatomic, strong) UITextView* questionTextView;

@end

@implementation MZAddPollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupUIViews];
    [self setupActionSelectors];
}

- (void)goToFeedView {
    [self.tabBarController setSelectedIndex:0];
}

#pragma mark - UI Setup

- (void)setupNavigationBar {
    
    [self.navigationItem setTitle:@"New Poll"];
    self.edgesForExtendedLayout = UIRectEdgeNone; //because label would go under navigaton bar
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x69D2E7);
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName: [UIFont systemFontOfSize:20.0f]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone                                                                                      target:self
                                                                                action:@selector(submitPoll)];
    doneButton.tintColor = UIColorFromRGB(0xF9A369);
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(goToFeedView)];
    cancelButton.tintColor = UIColorFromRGB(0xF9A369);
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setupUIViews {
    
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    self.questionCharCounterLabel = [[UILabel alloc]
                                     initWithFrame:CGRectMake(kHorizontalInsets/ 2, kVerticalInsets * 2,
                                                              2 * kHorizontalInsets, 2 * kVerticalInsets)];
    
    self.questionCharCounterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)MAX_CHAR_COUNT];
    self.questionCharCounterLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightSemibold];
    self.questionCharCounterLabel.textColor = [UIColor lightGrayColor];
    self.questionCharCounterLabel.textAlignment = NSTextAlignmentCenter;
    
    self.questionTextView = [[UITextView alloc]
                             initWithFrame:CGRectMake(3 * kHorizontalInsets, kVerticalInsets,
                                                      screenRect.width - 4 * kHorizontalInsets,
                                                      10 * kVerticalInsets)];
    
    [self.questionTextView setFont:[UIFont systemFontOfSize:20.0f]];
    self.questionTextView.scrollEnabled = NO;
    self.questionTextView.delegate = self;
    self.questionTextView.text = @"Enter your question...";
    self.questionTextView.textColor = [UIColor lightGrayColor];
    
    self.chosenImgView = [UIImageView newAutoLayoutView];
    self.chosenImgView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.buttonsView  = [UIView newAutoLayoutView];
    self.buttonsView.backgroundColor = UIColorFromRGB(0xF38630);
    
    self.selectImgBtn = [UIButton newAutoLayoutView];
    [self.selectImgBtn setTitle:@"Choose Photo" forState:UIControlStateNormal];
    
    self.takeImageBtn = [UIButton newAutoLayoutView];
    [self.takeImageBtn setTitle:@"Capture Photo" forState:UIControlStateNormal];
    
    [self.view addSubview:self.questionTextView];
    [self.view addSubview:self.chosenImgView];
    [self.view addSubview:self.questionCharCounterLabel];
    [self.buttonsView addSubview:self.takeImageBtn];
    [self.buttonsView addSubview:self.selectImgBtn];
    [self.view addSubview:self.buttonsView];
}

- (void)setupActionSelectors {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    [self.takeImageBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectImgBtn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Enter your question..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter your question...";
        textView.textColor = [UIColor lightGrayColor];
    }
    
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    //character count
    long int len = textView.text.length;
    self.questionCharCounterLabel.text=[NSString stringWithFormat:@"%ld", MAX_CHAR_COUNT - len];
    
    //dynamic height
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    UIEdgeInsets inset = textView.contentInset;
    newFrame.size = CGSizeMake(fixedWidth, newSize.height + inset.top + inset.bottom);
    textView.frame = newFrame;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    self.questionCharCounterLabel.textColor = [UIColor lightGrayColor];
    
    if ([textView.text length] + [text length] > MAX_CHAR_COUNT) {
        self.questionCharCounterLabel.textColor = [UIColor redColor];
        return NO;
    }
    
    return YES;
}

#pragma mark - AutoLayout

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self updateSubviewsConstraints];
}

- (void)updateSubviewsConstraints {
    
    if (!self.didSetupConstraints) {
        
        [self.chosenImgView autoPinEdge:ALEdgeTop
                                 toEdge:ALEdgeBottom
                                 ofView:self.questionTextView
                             withOffset:kVerticalInsets];
        
        [self.chosenImgView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.chosenImgView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.chosenImgView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.chosenImgView];
        self.chosenImgView.clipsToBounds = YES;
        
        [self.buttonsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.buttonsView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.selectImgBtn];
        
        [self.selectImgBtn autoPinEdge:ALEdgeTop
                                toEdge:ALEdgeTop
                                ofView:self.buttonsView
                            withOffset:0];
        [self.selectImgBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalInsets];
        
        [self.takeImageBtn autoPinEdge:ALEdgeTop
                                toEdge:ALEdgeTop
                                ofView:self.buttonsView
                            withOffset:0];
        [self.takeImageBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalInsets];
        
        self.didSetupConstraints = YES;
    }
}

#pragma mark - Keyboard Events

-(void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo  = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newButtonsViewFrame = self.buttonsView.frame;
    double tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    
    newButtonsViewFrame.origin.y = keyboardFrame.origin.y - newButtonsViewFrame.size.height - tabBarHeight;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.buttonsView.frame = newButtonsViewFrame;
        [self.buttonsView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:keyboardFrame.size.height - tabBarHeight];
    } completion:nil];
}

-(void)keyboardWillHide {
    
    //removing and readding the view to break the purelayout autolayout contsraints
    [self.buttonsView removeFromSuperview];
    [self.view addSubview:self.buttonsView];
    [self.buttonsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.buttonsView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.selectImgBtn];
}

-(void)dismissKeyboard {
    [self.questionTextView resignFirstResponder];
}

#pragma mark - Poll photo selection

- (void)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma  mark - UIImagePickerControllerDelegate 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //dismissing the controller before assigning solved didReceiveMemory warning as per stackoverflow suggestion
    //http://stackoverflow.com/questions/1834128/memory-warning-after-using-the-uiimagepicker-once
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.chosenImgView.image = chosenImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma  mark - Poll data preparation & submission

- (void)submitPoll {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops!"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    
    //checking input
    BOOL validInput = true;
    NSString *questionText = [self.questionTextView.text
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([questionText length] == 0 || [self.questionTextView.text isEqualToString:@"Enter your question..."]) {
        validInput = NO;
        alert.message = @"You forgot to add your question";
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if (self.chosenImgView.image == nil) {
        alert.message = @"You forgot to include your awesome photo";
        [self presentViewController:alert animated:YES completion:nil];
        validInput = NO;
    }
    
    if (validInput) {
        NSUserDefaults *deviceCache  = [NSUserDefaults standardUserDefaults];
        NSString *myName = [deviceCache objectForKey:@"my_name"];
        NSString *myID = [deviceCache objectForKey:@"my_id"];
        
        NSDictionary* params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.questionTextView.text, @"question",
                                myName, @"author_name",
                                myID, @"author_id",
                                self.chosenImgView.image, @"image",
                                nil];
        
        NSURL *requestURL = [NSURL URLWithString:kAddPollURL];
        [JDStatusBarNotification showWithStatus:@"uploading your poll" styleName:JDStatusBarStyleWarning];
        [self sendPostRequestWithParameters:params toURL:requestURL];
    }
}

- (void)sendPostRequestWithParameters:(NSDictionary*)params toURL:(NSURL*)requestURL {
    
    UIImage *imageToPost = [params objectForKey:@"image"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = [self compressImage:imageToPost];
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    // the server url to which the image (or the media) is uploaded. Use your server url here
    [request setURL:requestURL];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionUploadTask *postDataTask = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
           // NSLog(@"error: %@", [error userInfo]);
            [JDStatusBarNotification showWithStatus:@"didn't work :( try again" dismissAfter:2.0 styleName:JDStatusBarStyleWarning];
            [self.tabBarController setSelectedIndex:1];
        } else {
            [JDStatusBarNotification showWithStatus:@"woohoo! poll uploaded" dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
            //reset views
            self.questionTextView.text = @"Enter your question...";
            //because otherwise if the user cancels while typing and comes back to this view, the placeholder text won't appear
            //since it is the first responser, it will call textViewDidBeginEditing and remove the placeholder text
            [self dismissKeyboard];
            self.questionTextView.textColor = [UIColor lightGrayColor];
            self.questionCharCounterLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)MAX_CHAR_COUNT];
            self.chosenImgView.image = nil;
        }
    }];
    
    [postDataTask resume];
    [self goToFeedView];
}

- (NSData *)compressImage:(UIImage *)image {
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxWidth = 1920; //iphone 6 resolution
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualWidth > maxWidth) {
        actualHeight = (maxWidth * actualHeight) / actualWidth;
        actualWidth = maxWidth;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}

@end
