//
//  Constants.h
//  milzi
//
//  Created by Ahmed Nawar on 11/2/15.
//  Copyright © 2015 Ahmed Nawar. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kHorizontalInsets      15.0f
#define kVerticalInsets        10.0f
#define k7DaysInSeconds        7 * 24 * 60 * 60
//URLs
#define kServerURL @"http://milzi.webfactional.com/"
#define kGetFeedURL @"http://milzi.webfactional.com/"
#define kGetUserFeedURL @"http://milzi.webfactional.com/get-my-stuff"
#define kAddUserURL @"http://milzi.webfactional.com/adduser"
#define kAddPollURL @"http://milzi.webfactional.com/upload"



#endif /* Constants_h */
