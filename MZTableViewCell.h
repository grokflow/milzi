//
//  MZTableViewCell.h
//  milzi
//
//  Created by Ahmed Nawar on 10/20/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PureLayout.h"


@interface MZTableViewCell : UITableViewCell
@property NSString *authorLabelString;
@property NSString *questionLabelString;
@property NSString *imgUrlString;
@property (nonatomic, strong) UILabel* questionLabel;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UIImageView* mainImageView;
@property (nonatomic, strong) UIButton* yesButton;
@property (nonatomic, strong) UIButton* noButton;
@property (nonatomic, strong) UILabel* voteCountLabel;
@property (nonatomic, strong) UIView* cellSeparator;

- (void)updateFonts;


@end
