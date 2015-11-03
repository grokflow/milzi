//
//  FeedViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/16/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZFeedViewController.h"

static NSString *CellIdentifier = @"MilZiCellID";
NSMutableArray *dataArray;
NSUserDefaults *deviceCache;

@class MZNewUserViewController;

@implementation MZFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"milzi"];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x69D2E7);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName: [UIFont systemFontOfSize:28.0f]}];
    
    [self.tableView registerClass:[MZTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    deviceCache = [NSUserDefaults standardUserDefaults];
    
    dataArray = [[NSMutableArray alloc] init];
    [self getLatestUpdates];
    
    if ([deviceCache boolForKey:@"friend"] == NO) {
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        [self showNewUserScreen];
    }
    
    [self setupRefreshControl];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([dataArray count]) {
        return 1;
    } else {
        [self showErrorMessage:@"No data is currently available. Please pull down to refresh."];
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCustomCell:(MZTableViewCell*)cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewCell Configuration

- (void)configureCustomCell:(MZTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell updateFonts];
    
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    NSNumber *itemID = [dict objectForKey:@"ID"];
    NSString *author = [dict objectForKey:@"AuthorName"];
    NSString *question = [dict objectForKey:@"Question"];
    NSString *imgURL = [NSString stringWithFormat:@"%@%@",kServerURL, [dict objectForKey:@"ImgURL"]];
    
    NSUInteger yesVotes = [[dict objectForKey:@"YesVotes"] integerValue];
    NSUInteger noVotes = [[dict objectForKey:@"NoVotes"] integerValue];
    NSUInteger totalVotes = yesVotes + noVotes;
    
    cell.questionLabel.text = question;
    cell.nameLabel.text = [NSString stringWithFormat:@"by %@", author];
    [cell.mainImageView sd_setImageWithURL:[NSURL URLWithString:imgURL]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [cell setNeedsUpdateConstraints];
                                     [cell updateConstraintsIfNeeded];
                                 }];
    
    cell.yesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.noButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.yesButton.tag = cell.noButton.tag = indexPath.row;
    [cell enableCellButtons];
    
    [cell.yesButton addTarget:self action:@selector(tappedYes:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noButton addTarget:self action:@selector(tappedNo:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *myVote = [deviceCache stringForKey:[itemID stringValue]];
    
    if (myVote) {
        //adding 1 to all the calculations since votes in this session are not reflected in the dictionary retrieved from the server since it is immutable.
        // this will skew the results by one when we sync with the server
        [cell disableCellButtons];
        double yesPercent, noPercent;
        ++totalVotes;
        if ([myVote isEqualToString:@"yes"]) {
            ++yesVotes;
            cell.yesButton.layer.borderColor = UIColorFromRGB(0xF38630).CGColor;
        } else if ([myVote isEqualToString:@"no"]) {
            ++noVotes;
            cell.noButton.layer.borderColor = UIColorFromRGB(0xF38630).CGColor;
        }
        
        yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
        noPercent = ((double)noVotes / totalVotes) * 100.0f;
        
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    } else if (totalVotes == 0) {
        cell.voteCountLabel.text = @"Be the first to vote!";
    } else {
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes", totalVotes];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

#pragma mark - User input handlers

-(void)tappedYes:(UIButton *)sender {
    
    //sender.tag has the cell's IndexPath.row
    NSMutableDictionary *dict = [dataArray objectAtIndex:sender.tag];
    NSString *itemID = [[dict objectForKey:@"ID"] stringValue];
    [deviceCache setValue:@"yes" forKey:itemID];
    [deviceCache synchronize];
    
    sender.layer.borderColor = UIColorFromRGB(0xF38630).CGColor;
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    NSUInteger yesVotes = [[dict objectForKey:@"YesVotes"] integerValue] + 1;
    NSUInteger noVotes = [[dict objectForKey:@"NoVotes"] integerValue];
    NSUInteger totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    [cell disableCellButtons];
    [self sendVotingRequestForID:itemID andAction:@"upvote"];
}

-(void)tappedNo:(UIButton *)sender {
    
    //sender.tag has the cell's IndexPath.row
    NSMutableDictionary *dict = [dataArray objectAtIndex:sender.tag];
    NSString *itemID = [[dict objectForKey:@"ID"] stringValue];
    
    [deviceCache setValue:@"no" forKey:itemID];
    [deviceCache synchronize];
    sender.layer.borderColor = UIColorFromRGB(0xF38630).CGColor;
    
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    NSUInteger yesVotes = [[dict objectForKey:@"YesVotes"] integerValue];
    NSUInteger noVotes = [[dict objectForKey:@"NoVotes"] integerValue] + 1;
    NSUInteger totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    [cell disableCellButtons];
    [self sendVotingRequestForID:itemID andAction:@"downvote"];
}

#pragma mark - Network Calls

- (void)getLatestUpdates {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:kGetFeedURL]  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            [self showErrorMessage:[NSString stringWithFormat:@"%@\nCheck your internet connection and pull to grab some gems", [error localizedDescription]]];
            [self.refreshControl endRefreshing];
            
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            dataArray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
    
    [dataTask resume];
}

-(void)sendVotingRequestForID:(NSString *)ID andAction:(NSString *)action {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURL *voteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kServerURL, action]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:voteURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString * params = [NSString stringWithFormat:@"id=%@", ID];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    
    [postDataTask resume];
}

#pragma mark - UI Utilities

- (void)showNewUserScreen {
    
    MZNewUserViewController *newUserViewController = [[MZNewUserViewController alloc] init];
    newUserViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    newUserViewController.feedVC = self;
    
    self.navigationController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:newUserViewController animated:YES completion:nil];
    
}

- (void) setupRefreshControl {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = UIColorFromRGB(0xF38630);
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestUpdates)
                  forControlEvents:UIControlEventValueChanged];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"grabbing more gems" attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

- (void)showErrorMessage:(NSString *)error {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 50, self.view.bounds.size.height)];
    
    messageLabel.text = error;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 3;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:18];
    
    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end
