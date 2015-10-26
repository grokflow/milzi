//
//  FeedViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/16/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZFeedViewController.h"

NSString *url = @"http://192.168.1.125:5000/";
NSURLSession *session;
NSMutableArray *dataArray;
static NSString *CellIdentifier = @"MilZiCellID";
NSUserDefaults *deviceCache;
@interface MZFeedViewController ()

@end

@implementation MZFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"milzi"];
    
    
    [self.tableView registerClass:[MZTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    // Self-sizing table view cells in iOS 8 are enabled when the estimatedRowHeight property of the table view is set to a non-zero value.
    // Setting the estimated row height prevents the table view from calling tableView:heightForRowAtIndexPath: for every row in the table on first load;
    // it will only be called as cells are about to scroll onscreen. This is a major performance optimization.
    self.tableView.estimatedRowHeight = 200.0; // set this to whatever your "average" cell height is; it doesn't need to be very accurate
    session = [NSURLSession sharedSession];
    dataArray = [[NSMutableArray alloc] init];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dataArray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];
    
    deviceCache = [NSUserDefaults standardUserDefaults];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCustomCell:(MZTableViewCell*)cell atIndexPath:indexPath];
    
    return cell;
}
- (void)configureCustomCell:(MZTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell updateFonts];
    
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    NSNumber *itemID = [dict objectForKey:@"id"];
    NSString *author = [dict objectForKey:@"author"];
    NSString *question = [dict objectForKey:@"question"];
    NSString *imgURL = [NSString stringWithFormat:@"%@%@",url, [dict objectForKey:@"img-url"]];
    
    long int yesVotes = [[dict objectForKey:@"yes"] integerValue];
    long int noVotes = [[dict objectForKey:@"no"] integerValue];
    long int totalVotes = yesVotes + noVotes;
    
    cell.questionLabel.text = question;
    cell.nameLabel.text = [NSString stringWithFormat:@"by %@", author];
    [cell.mainImageView sd_setImageWithURL:[NSURL URLWithString:imgURL]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [cell setNeedsUpdateConstraints];
                                     [cell updateConstraintsIfNeeded];
                                 }];

    cell.yesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.noButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.yesButton.tag = cell.noButton.tag = [itemID integerValue];
    
    [cell.yesButton addTarget:self action:@selector(tappedYes:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noButton addTarget:self action:@selector(tappedNo:) forControlEvents:UIControlEventTouchUpInside];

   
    if (totalVotes == 0)
    {
        cell.voteCountLabel.text = @"Be the first to vote!";
    } else
    {
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes", totalVotes];
    }
    

    NSString *myVote = [deviceCache stringForKey:[itemID stringValue]];
    NSLog(@"myvote: %@", myVote);
    if (myVote)
    {
        double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
        double noPercent = ((double)noVotes / totalVotes) * 100.0f;
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
        if ([myVote isEqualToString:@"yes"])
            cell.yesButton.layer.borderColor = [UIColor redColor].CGColor;
        else if ([myVote isEqualToString:@"no"])
            cell.noButton.layer.borderColor = [UIColor redColor].CGColor;
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}
-(void)tappedYes:(UIButton *)sender
{
    NSString *key =[@(sender.tag) stringValue];
    NSLog(@"key: %@", key);
    [deviceCache setValue:@"yes" forKey:[@(sender.tag) stringValue]];
    [deviceCache synchronize];
    
    sender.layer.borderColor = [UIColor redColor].CGColor;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *dict = [dataArray objectAtIndex:indexPath.row];

    long int yesVotes = [[dict objectForKey:@"yes"] integerValue] + 1;
    long int noVotes = [[dict objectForKey:@"no"] integerValue];
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];

}

-(void)tappedNo:(UIButton *)sender
{
    [deviceCache setValue:@"no" forKey:[@(sender.tag) stringValue]];
    [deviceCache synchronize];
    sender.layer.borderColor = [UIColor redColor].CGColor;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    
    long int yesVotes = [[dict objectForKey:@"yes"] integerValue];
    long int noVotes = [[dict objectForKey:@"no"] integerValue] + 1;
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
}

@end
