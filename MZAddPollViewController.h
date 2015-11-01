//
//  MZAddPollViewController.h
//  milzi
//
//  Created by Ahmed Nawar on 10/27/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#define UIColorFromRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#include "JDStatusBarNotification.h"

@interface MZAddPollViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>


@end
