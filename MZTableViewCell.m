//
//  MZTableViewCell.m
//  milzi
//
//  Created by Ahmed Nawar on 10/20/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZTableViewCell.h"
#define kHorizontalInsets      15.0f
#define kVerticalInsets        10.0f

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MZTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *cellSeparator;

@end


@implementation MZTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.questionLabel = [UILabel newAutoLayoutView];
        [self.questionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.questionLabel setNumberOfLines:3];
        [self.questionLabel setTextAlignment:NSTextAlignmentLeft];
        [self.questionLabel setTextColor:[UIColor blackColor]];
        
        self.nameLabel = [UILabel newAutoLayoutView];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setTextColor:[UIColor darkGrayColor]];
        
        self.mainImageView = [UIImageView newAutoLayoutView];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mainImageView.userInteractionEnabled = YES;

        self.yesButton = [UIButton newAutoLayoutView];
        [self.yesButton setTitle:@"Yes" forState:UIControlStateNormal];
        //self.yesButton.backgroundColor = [UIColor lightGrayColor];
        self.yesButton.backgroundColor = UIColorFromRGB(0xA7DBD8);
        self.yesButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.yesButton.layer.borderWidth = 2.5f;
        self.yesButton.clipsToBounds = YES;

        self.noButton = [UIButton newAutoLayoutView];
        [self.noButton setTitle:@"No" forState:UIControlStateNormal];
        self.noButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.noButton.backgroundColor = UIColorFromRGB(0xA7DBD8);
        self.noButton.layer.borderWidth = 2.5f;
        self.noButton.clipsToBounds = YES;
        
        self.voteCountLabel = [UILabel newAutoLayoutView];
        [self.voteCountLabel setTextAlignment:NSTextAlignmentLeft];
        [self.voteCountLabel setTextColor:[UIColor darkGrayColor]];
        self.voteCountLabel.text = @"votes";
        
        self.cellSeparator = [UIView newAutoLayoutView];
        self.cellSeparator.backgroundColor = UIColorFromRGB(0xE0E4CC);//0xe7e7e7);
        
        [self.contentView addSubview:self.questionLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.mainImageView];
        [self.mainImageView addSubview:self.yesButton];
        [self.mainImageView addSubview:self.noButton];
        [self.contentView addSubview:self.voteCountLabel];
        [self.contentView addSubview:self.cellSeparator];
        
        [self updateFonts];
    }
    return self;
}

- (void)updateFonts
{
    self.questionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.voteCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
}

- (void)updateConstraints
{
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    
    if (!self.didSetupConstraints) {
        
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kVerticalInsets];
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalInsets];
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalInsets];
        
        [self.nameLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.questionLabel withOffset:0];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kHorizontalInsets];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kHorizontalInsets];
        
        CGSize img_size = self.mainImageView.image.size;
        [self.mainImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel withOffset:kVerticalInsets];
        [self.mainImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.mainImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.mainImageView autoSetDimension:ALDimensionHeight toSize:floor((img_size.height * screenRect.width)/ img_size.width)];
        self.mainImageView.clipsToBounds = YES;
        
        [self.yesButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kVerticalInsets];
        [self.yesButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalInsets];
        [self.yesButton autoSetDimension:ALDimensionHeight toSize:screenRect.width * 0.15];
        [self.yesButton autoSetDimension:ALDimensionWidth toSize:screenRect.width * 0.15];
        
        [self.noButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kVerticalInsets];
        [self.noButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalInsets];
        [self.noButton autoSetDimension:ALDimensionHeight toSize:screenRect.width * 0.15];
        [self.noButton autoSetDimension:ALDimensionWidth toSize:screenRect.width * 0.15];


        [self.voteCountLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mainImageView withOffset:kVerticalInsets];
        [self.voteCountLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalInsets];
        
        [self.cellSeparator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.voteCountLabel withOffset:kVerticalInsets];
        [self.cellSeparator autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.cellSeparator autoSetDimension:ALDimensionHeight toSize:15];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.noButton.layer.cornerRadius = floor(self.noButton.bounds.size.width / 2.0);
    self.yesButton.layer.cornerRadius = floor(self.yesButton.bounds.size.width / 2.0);
}

- (void)disableCellButtons
{
    self.yesButton.userInteractionEnabled = NO;
    self.noButton.userInteractionEnabled = NO;
}

- (void)enableCellButtons
{
    self.yesButton.userInteractionEnabled = YES;
    self.noButton.userInteractionEnabled = YES;
}

@end
