//
//  MZMyItemsViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/30/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZMyItemsViewController.h"

NSString *_BASE_URL = @"http://10.0.0.2:5000/";
static NSString *CellIdentifier = @"MilZiCellID";
NSURLSession *_session;
NSMutableArray *myDataArray;
NSUserDefaults *_deviceCache;

@interface MZMyItemsViewController ()

@end

@implementation MZMyItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _deviceCache = [NSUserDefaults standardUserDefaults];

    [self.navigationItem setTitle:[_deviceCache objectForKey:@"my_name"]];
    
    [self.tableView registerClass:[MZTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    _session = [NSURLSession sessionWithConfiguration:configuration];
    
    myDataArray = [[NSMutableArray alloc] init];
    [self getLatestUpdates];
    
    [self setupRefreshControl];
}


- (void) setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestUpdates)
                  forControlEvents:UIControlEventValueChanged];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"grabbing more of your gems" attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    
    
}
- (void)getLatestUpdates
{
    NSString *updatesURL = [NSString stringWithFormat:@"%@get-my-stuff", _BASE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:updatesURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    

    [request setHTTPMethod:@"POST"];
    NSString * params = [NSString stringWithFormat:@"id=%@", [_deviceCache objectForKey:@"my_id"]];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];

    
    NSURLSessionDataTask *dataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        myDataArray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
        });
    }];
    [dataTask resume];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([myDataArray count])
    {
        return 1;
        
    } else
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myDataArray count];
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
    
    NSDictionary *dict = [myDataArray objectAtIndex:indexPath.row];
    NSNumber *itemID = [dict objectForKey:@"ID"];
    NSString *author = [dict objectForKey:@"AuthorName"];
    NSString *question = [dict objectForKey:@"Question"];
    NSString *imgURL = [NSString stringWithFormat:@"%@%@",_BASE_URL, [dict objectForKey:@"ImgURL"]];
    
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
    cell.yesButton.tag = cell.noButton.tag = indexPath.row;
    [cell enableCellButtons];
    
    
    [cell.yesButton addTarget:self action:@selector(tappedYes:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noButton addTarget:self action:@selector(tappedNo:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSString *myVote = [_deviceCache stringForKey:[itemID stringValue]];
    
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
    }
    
    if (totalVotes == 0)
    {
        cell.voteCountLabel.text = @"Be the first to vote!";
    } else
    {
        cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes", totalVotes];
    }
    
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
}

-(void)tappedYes:(UIButton *)sender
{
    //sender.tag has the cell's IndexPath.row
    NSMutableDictionary *dict = [myDataArray objectAtIndex:sender.tag];
    NSString *itemID = [[dict objectForKey:@"ID"] stringValue];
    [_deviceCache setValue:@"yes" forKey:itemID];
    [_deviceCache synchronize];
    
    sender.layer.borderColor = [UIColor redColor].CGColor;
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    long int yesVotes = [[dict objectForKey:@"YesVotes"] integerValue] + 1;
    long int noVotes = [[dict objectForKey:@"NoVotes"] integerValue];
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    [cell disableCellButtons];
    [self sendVotingRequestForID:itemID andAction:@"upvote"];
}

-(void)tappedNo:(UIButton *)sender
{
    //sender.tag has the cell's IndexPath.row
    NSMutableDictionary *dict = [myDataArray objectAtIndex:sender.tag];
    NSString *itemID = [[dict objectForKey:@"ID"] stringValue];
    
    [_deviceCache setValue:@"no" forKey:itemID];
    [_deviceCache synchronize];
    sender.layer.borderColor = [UIColor redColor].CGColor;
    
    MZTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    long int yesVotes = [[dict objectForKey:@"YesVotes"] integerValue];
    long int noVotes = [[dict objectForKey:@"NoVotes"] integerValue] + 1;
    long int totalVotes = yesVotes + noVotes;
    double yesPercent = ((double)yesVotes / totalVotes) * 100.0f;
    double noPercent = ((double)noVotes / totalVotes) * 100.0f;
    cell.voteCountLabel.text = [NSString stringWithFormat:@"%ld votes (%g%%, %g%%)", totalVotes, ceil(yesPercent),floor(noPercent)];
    
    [cell disableCellButtons];
    [self sendVotingRequestForID:itemID andAction:@"downvote"];
}

-(void)sendVotingRequestForID:(NSString *)ID andAction:(NSString *)action
{
    NSURL *voteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_BASE_URL, action]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:voteURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString * params = [NSString stringWithFormat:@"id=%@", ID];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    
    [postDataTask resume];
}



@end
