//
//  MZTableViewCell.m
//  milzi
//
//  Created by Ahmed Nawar on 10/20/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZTableViewCell.h"
#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f


@interface MZTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;

@end


@implementation MZTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.questionLabel = [UILabel newAutoLayoutView];
        [self.questionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.questionLabel setNumberOfLines:1];
        [self.questionLabel setTextAlignment:NSTextAlignmentLeft];
        [self.questionLabel setTextColor:[UIColor blackColor]];
        
        self.nameLabel = [UILabel newAutoLayoutView];
        [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameLabel setNumberOfLines:0];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setTextColor:[UIColor darkGrayColor]];
        
        self.mainImageView = [UIImageView newAutoLayoutView];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.mainImageView.userInteractionEnabled = YES;

        self.yesButton = [UIButton newAutoLayoutView];
        [self.yesButton setTitle:@"Yes" forState:UIControlStateNormal];
        self.yesButton.backgroundColor = [UIColor lightGrayColor];
        self.yesButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.yesButton.layer.borderWidth = 2.5f;
        self.yesButton.clipsToBounds = YES;

        self.noButton = [UIButton newAutoLayoutView];
        [self.noButton setTitle:@"No" forState:UIControlStateNormal];
        self.noButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.noButton.backgroundColor = [UIColor lightGrayColor];
        self.noButton.layer.borderWidth = 2.5f;
        self.noButton.clipsToBounds = YES;
        
        self.voteCountLabel = [UILabel newAutoLayoutView];
        [self.voteCountLabel setTextAlignment:NSTextAlignmentLeft];
        [self.voteCountLabel setTextColor:[UIColor darkGrayColor]];
        self.voteCountLabel.text = @"272 votes";
        
        self.cellSeparator = [UIView newAutoLayoutView];
        self.cellSeparator.backgroundColor = [UIColor lightGrayColor];
        
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
    self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)updateConstraints
{
    CGSize screenRect = [[UIScreen mainScreen] bounds].size;
    
    if (!self.didSetupConstraints) {
        
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
        [self.questionLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
        
        
        [self.nameLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.questionLabel withOffset:0];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLabelHorizontalInsets];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kLabelHorizontalInsets];
        
        CGSize img_size = self.mainImageView.image.size;
        
        [self.mainImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel withOffset:kLabelVerticalInsets];
        [self.mainImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.mainImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.mainImageView autoSetDimension:ALDimensionHeight toSize:floor((img_size.height * 320)/ img_size.width)];
        self.mainImageView.clipsToBounds = YES;
        
        [self.yesButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
        [self.yesButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
        [self.yesButton autoSetDimension:ALDimensionHeight toSize:screenRect.width * 0.15];
        [self.yesButton autoSetDimension:ALDimensionWidth toSize:screenRect.width * 0.15];
        
        [self.noButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
        [self.noButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
        [self.noButton autoSetDimension:ALDimensionHeight toSize:screenRect.width * 0.15];
        [self.noButton autoSetDimension:ALDimensionWidth toSize:screenRect.width * 0.15];

        

        [self.voteCountLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.mainImageView withOffset:kLabelVerticalInsets];
        [self.voteCountLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
        
        [self.cellSeparator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.voteCountLabel withOffset:kLabelVerticalInsets];
        
        [self.cellSeparator autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.cellSeparator autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.cellSeparator autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [self.cellSeparator autoSetDimension:ALDimensionHeight toSize:15];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.noButton.layer.cornerRadius = floor(self.noButton.bounds.size.width / 2.0);
    self.yesButton.layer.cornerRadius = floor(self.yesButton.bounds.size.width / 2.0);

//    [self.contentView layoutIfNeeded];

}


@end
