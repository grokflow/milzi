//
//  MZMyItemsViewController.m
//  milzi
//
//  Created by Ahmed Nawar on 10/30/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "MZMyItemsViewController.h"


@implementation MZMyItemsViewController

- (void)viewDidLoad {
    
    self.deviceCache = [NSUserDefaults standardUserDefaults];
    self.navBarTitleString = [self.deviceCache objectForKey:@"my_name"];
    self.refreshControlMessage = @"grabbing more of your gems";
    [super viewDidLoad];
}

- (void)getLatestUpdates {
   
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSString *requestURL = [NSString stringWithFormat:@"%@?id=%@", kGetUserFeedURL, [self.deviceCache objectForKey:@"my_id"]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:requestURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
           // NSLog(@"error: %@", error);
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

@end
