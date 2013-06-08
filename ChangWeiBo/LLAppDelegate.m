//
//  LLAppDelegate.m
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLAppDelegate.h"

@implementation LLAppDelegate

- (void)initializePlat
{
	/**
	 连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
	 http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
    **/
	[ShareSDK connectSinaWeiboWithAppKey:@"2323109452"
										appSecret:@"076bbc82624162cc35e9a610247eb3ca"
									 redirectUri:@"https://api.weibo.com/oauth2/default.html"];
	
	/**
	 连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
	 http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
	 **/
	[ShareSDK connectWeChatWithAppId:@"wx87c8783c74a2b205" wechatCls:[WXApi class]];
	
	/**
	 连接豆瓣应用以使用相关功能，此应用需要引用DouBanConnection.framework
	 http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
	 **/
	[ShareSDK connectDoubanWithAppKey:@"0187f5541cee0d160497dffc56ca2742"
									appSecret:@"7546279bbf8dc8cd"
								 redirectUri:@"http://weibo.com/oasisweng"];
	
	/**
	 连接人人网应用以使用相关功能，此应用需要引用RenRenConnection.framework
	 http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
	 **/
	[ShareSDK connectRenRenWithAppKey:@"5aa6a65d01eb48d2a72cbd66865748b5"
									appSecret:@"86b7ff25f81841ef85575a6b42d6c5ca"];
	
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	[ShareSDK registerApp:@"2c60e3e1a22"];
	[self initializePlat];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGLES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [ShareSDK handleOpenURL:url
							  wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return [ShareSDK handleOpenURL:url
					 sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}


@end
