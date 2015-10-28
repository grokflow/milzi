//
//  FeedViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/16/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZFeedViewController.h"

NSString *url = @"http://10.0.0.2:5000/";
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

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    session = [NSURLSession sessionWithConfiguration:configuration];
    
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
    NSNumber *itemID = [dict objectForKey:@"ID"];
    NSString *author = [dict objectForKey:@"AuthorName"];
    NSString *question = [dict objectForKey:@"Question"];
    NSString *imgURL = [NSString stringWithFormat:@"%@%@",url, [dict objectForKey:@"ImgURL"]];
    
    long int yesVotes = [[dict objectForKey:@"YesVotes"] integerValue];
    long int noVotes = [[dict objectForKey:@"NoVotes"] integerValue];
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
    [cell enableCellButtons];
    
    
    [cell.yesButton addTarget:self action:@selector(tappedYes:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noButton addTarget:self action:@selector(tappedNo:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSString *myVote = [deviceCache stringForKey:[itemID stringValue]];
    NSLog(@"myvote: %@", myVote);
    
    NSLog(@"total votes: %ld", totalVotes);
    
    if (myVote)
    {
        //adding 1 to all the calculations since votes in this session are not reflected in the dictionary retrieved from the server since it is immutable.
        // this will skew the results by one when we sync with the server
        [cell disableCellButtons];
        double yesPercent, noPercent;
        ++totalVotes;
        if ([myVote isEqualToString:@"yes"])
        {
            ++yesVotes;
            cell.yesButton.layer.borderColor = [UIColor redColor].CGColor;
        }
        else if ([myVote isEqualToString:@"no"])
        {
            ++noVotes;
            cell.noButton.layer.borderColor = [UIColor redColor].CGColor;
        }
        yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
        noPercent = ((double)noVotes / totalVotes) * 100.0f;
        
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    } else if (totalVotes == 0)
    {
        cell.voteCountLabel.text = @"Be the first to vote!";
    } else
    {
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes", totalVotes];
    }
    
    
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

//to do, combine the 2 voting network calls to one
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
    
    long int yesVotes = [[dict objectForKey:@"YesVotes"] integerValue] + 1;
    long int noVotes = [[dict objectForKey:@"NoVotes"] integerValue];
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    
    [cell disableCellButtons];
    NSURL *upvoteurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@upvote",url]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:upvoteurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString * params = [NSString stringWithFormat:@"id=%@", key];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@", [response URL]);
    }];
    
    [postDataTask resume];
    
}

-(void)tappedNo:(UIButton *)sender
{
    [deviceCache setValue:@"no" forKey:[@(sender.tag) stringValue]];
    [deviceCache synchronize];
    sender.layer.borderColor = [UIColor redColor].CGColor;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [dataArray objectAtIndex:indexPath.row];
    long int yesVotes = [[dict objectForKey:@"YesVotes"] integerValue];
    long int noVotes = [[dict objectForKey:@"NoVotes"] integerValue] + 1;
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    [cell disableCellButtons];
    
    NSURL *upvoteurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@downvote",url]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:upvoteurl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString * params = [NSString stringWithFormat:@"id=%@", [@(sender.tag) stringValue]];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response: %@", [response URL]);
    }];
    
    [postDataTask resume];
    
}

@end
