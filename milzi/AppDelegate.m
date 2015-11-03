//
//  AppDelegate.m
//  milzi
//
//  Created by Ahmed Nawar on 10/15/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#import "AppDelegate.h"
#import "MZFeedViewController.h"
#import "MZAddPollViewController.h"
#import "MZMyItemsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Caching
    SDImageCache *sharedCache = [SDImageCache sharedImageCache];
    sharedCache.maxCacheAge = k7DaysInSeconds;
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITabBarController *tabBars = [[UITabBarController alloc] init];

    MZFeedViewController *feedViewController = [[MZFeedViewController alloc] init];
    MZAddPollViewController *addPollViewController = [[MZAddPollViewController alloc] init];
    MZMyItemsViewController *myItemsViewController = [[MZMyItemsViewController alloc] init];
    
    UINavigationController *feedNavigationController = [[UINavigationController alloc] initWithRootViewController:feedViewController];
    feedNavigationController.tabBarItem.title = @"feed";
    feedNavigationController.tabBarItem.image = [UIImage imageNamed:@"globe_outline"];

    
    UINavigationController *pollNavigationController = [[UINavigationController alloc] initWithRootViewController:addPollViewController];
    pollNavigationController.tabBarItem.title = @"add";
    pollNavigationController.tabBarItem.image = [UIImage imageNamed:@"add"];

    
    UINavigationController *myStuffNavigationController = [[UINavigationController alloc] initWithRootViewController:myItemsViewController];
    myStuffNavigationController.tabBarItem.title = @"mine";
    myStuffNavigationController.tabBarItem.image = [UIImage imageNamed:@"home_outline"];
    

    NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithObjects:feedNavigationController,
                                                 pollNavigationController,
                                                 myStuffNavigationController,
                                                 nil];

    tabBars.viewControllers = localViewControllersArray;
    tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);
    self.window.rootViewController = tabBars;
        
    // Override point for customization after application launch
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
