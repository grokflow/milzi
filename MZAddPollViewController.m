//
//  MZAddPollViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/27/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZAddPollViewController.h"

#define kHorizontalInsets      15.0f
#define kVerticalInsets        10.0f



@interface MZAddPollViewController ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *questionCharCounterLabel;
@property (nonatomic, strong) UIImageView *chosenImgView;
@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIButton *takeImageBtn, *selectImgBtn;
@property (nonatomic, strong) UITextView* questionTextView;
@end

@implementation MZAddPollViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(submitPoll:)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(doneEditing)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;

    
    [self.navigationItem setTitle:@"New Poll"];
    self.edgesForExtendedLayout = UIRectEdgeNone; //because label would go under navigaton bar
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    
    self.questionCharCounterLabel = [[UILabel alloc]
                                     initWithFrame:CGRectMake(kHorizontalInsets/ 2, kVerticalInsets * 2,
                                                              2 * kHorizontalInsets, 2 * kVerticalInsets)];
    
    self.questionCharCounterLabel.text =  @"100";
    self.questionCharCounterLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightSemibold];
    self.questionCharCounterLabel.textColor = [UIColor lightGrayColor];
    self.questionCharCounterLabel.textAlignment = NSTextAlignmentCenter;

    NSLog(@"label frame %f %f", self.questionCharCounterLabel.frame.origin.x, self.questionCharCounterLabel.frame.origin.y);
    self.questionTextView = [[UITextView alloc]
                             initWithFrame:CGRectMake(3 * kHorizontalInsets, kVerticalInsets,
                                                      screenRect.width - 4 * kHorizontalInsets,
                                                      10 * kVerticalInsets)];
    
    NSLog(@"textview frame %f %f", self.questionTextView.frame.origin.x, self.questionTextView.frame.origin.y);

    [self.questionTextView setFont:[UIFont systemFontOfSize:20.0f]];
    self.questionTextView.scrollEnabled = NO;
    self.questionTextView.delegate = self;
    self.questionTextView.text = @"Enter your question...";
    self.questionTextView.textColor = [UIColor lightGrayColor]; //optional
    
    self.chosenImgView = [UIImageView newAutoLayoutView];
    self.chosenImgView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.buttonsView  = [UIView newAutoLayoutView];
    self.buttonsView.backgroundColor = [UIColor greenColor];
    
    self.selectImgBtn = [UIButton newAutoLayoutView];
    [self.selectImgBtn setTitle:@"Choose Photo" forState:UIControlStateNormal];
    
    self.takeImageBtn = [UIButton newAutoLayoutView];
    [self.takeImageBtn setTitle:@"Capture Photo" forState:UIControlStateNormal];
    
    [self.takeImageBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectImgBtn addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:self.questionTextView];
    [self.view addSubview:self.chosenImgView];
    [self.view addSubview:self.questionCharCounterLabel];
    [self.buttonsView addSubview:self.takeImageBtn];
    [self.buttonsView addSubview:self.selectImgBtn];
    [self.view addSubview:self.buttonsView];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)submitPoll:(UIButton *)sender
{
    //checking input
    
    BOOL validInput = true;
    NSString *questionText = [self.questionTextView.text
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([questionText length] == 0)
        validInput = NO;
    if (self.chosenImgView.image == nil)
        validInput = NO;
    
    if (validInput)
    {
        NSLog(@"image view %@", self.chosenImgView.image);

        [self sendPostRequest];
        
    }
    
}
-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *userInfo  = notification.userInfo;
    NSValue      *value = userInfo[UIKeyboardFrameEndUserInfoKey];
    
    
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.buttonsView.superview convertRect:keyboardFrame fromView:nil];
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    
    CGRect newTextFieldFrame = self.buttonsView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height - self.tabBarController.tabBar.bounds.size.height;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.buttonsView.frame = newTextFieldFrame;
        
        [self.buttonsView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:keyboardFrame.size.height - self.tabBarController.tabBar.bounds.size.height];
    } completion:nil];
}

-(void)keyboardOffScreen:(NSNotification *)notification
{
    [self.buttonsView removeFromSuperview];
    [self.view addSubview:self.buttonsView];
    [self.buttonsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.buttonsView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.selectImgBtn];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateSubviewsConstraints];
}

-(void)dismissKeyboard
{
    [self.questionTextView resignFirstResponder];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter your question..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter your question...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    //character count
    long int len = textView.text.length;
    self.questionCharCounterLabel.text=[NSString stringWithFormat:@"%ld", 100 - len];
    
    //dynamic height
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    UIEdgeInsets inset = textView.contentInset;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height + inset.top + inset.bottom);
    // NSLog(@"new height: %f %f ", newSize.height, newFrame.size.height);
    textView.frame = newFrame;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.questionCharCounterLabel.textColor = [UIColor lightGrayColor];
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            return YES;
        }
    }
    else if([textView.text length] + [text length] > 100)
    {
        self.questionCharCounterLabel.textColor = [UIColor redColor];
        return NO;
    }
    return YES;
}
- (void)updateSubviewsConstraints
{
    NSLog(@"update view constraints ");
    
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    
    if (!self.didSetupConstraints) {
        
        [self.chosenImgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom
                                 ofView:self.questionTextView
                             withOffset:kVerticalInsets];
        
        [self.chosenImgView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.chosenImgView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.chosenImgView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.chosenImgView];
        self.chosenImgView.clipsToBounds = YES;
        
        [self.buttonsView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.buttonsView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.selectImgBtn];
        
        [self.selectImgBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop
                                ofView:self.buttonsView
                            withOffset:0];
        
        [self.selectImgBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalInsets];
        
        [self.takeImageBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop
                                ofView:self.buttonsView
                            withOffset:0];
        
        [self.takeImageBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalInsets];
        self.didSetupConstraints = YES;
    }
    
}

- (void)takePhoto:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.chosenImgView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)sendPostRequest
{
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:self.questionTextView.text forKey:@"question"];
    [_params setObject:@"new" forKey:@"author_name"];
    [_params setObject:@(177) forKey:@"author_id"];
    
    UIImage *imageToPost = self.chosenImgView.image;
    
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
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 0.5);
    if (imageData) {
        NSLog(@"in image data");
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
    //NSURL* requestURL = [NSURL URLWithString:@"10.0.0.2:5000/upload"];
    
    NSString *urlString = @"http://10.0.0.2:5000/upload";
    NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setURL:requestURL];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    
    
    NSURLSessionUploadTask *postDataTask = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@", [response URL]);
        NSLog(@"error: %@", [error userInfo]);
    }];
    [postDataTask resume];
    
    
}
@end
