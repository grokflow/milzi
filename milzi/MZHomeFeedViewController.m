//
//  MZHomeFeedViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 11/3/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZHomeFeedViewController.h"

@class MZNewUserViewController;

@implementation MZHomeFeedViewController

- (void)viewDidLoad
{
    self.refreshControlMessage = @"grabbing more gems";
    self.navBarTitleString = @"milzi";
    
    [super viewDidLoad];
    
    //new user
    if ([self.deviceCache boolForKey:@"friend"] == NO) {
        //disable interaction so that the user can't bypass the signup screen
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        [self showNewUserScreen];
    }
}

- (void)getLatestUpdates {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:kGetFeedURL]  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            //NSLog(@"error: %@", error);
            [self showErrorMessage:[NSString stringWithFormat:@"%@\nCheck your internet connection and pull to grab some gems", [error localizedDescription]]];
            [self.refreshControl endRefreshing];
            
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.dataArray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
    
    [dataTask resume];
    
}

- (void)showNewUserScreen {
    
    MZNewUserViewController *newUserViewController = [[MZNewUserViewController alloc] init];
    newUserViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    newUserViewController.feedVC = self;
    
    self.navigationController.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:newUserViewController animated:YES completion:nil];
}

@end
