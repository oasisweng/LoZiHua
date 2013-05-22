//
//  LLAppDelegate.h
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <QQApi/QQApi.h>

@interface LLAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
