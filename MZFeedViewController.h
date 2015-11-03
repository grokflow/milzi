//
//  FeedViewController.h
//  milzi
//
//  Created by Ahmed Nawar on 10/16/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTableViewCell.h"
#import "Constants.h"

@interface MZFeedViewController : UITableViewController

@property(strong, nonatomic) NSString *navBarTitleString;
@property(strong, nonatomic) NSString *refreshControlMessage;
@property(strong, nonatomic) NSMutableArray *dataArray;
@property(strong, nonatomic) NSUserDefaults *deviceCache;

- (void)getLatestUpdates;
- (void)showErrorMessage:(NSString *)error;

@end
