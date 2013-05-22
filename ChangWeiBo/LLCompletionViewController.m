//
//  LLCompletionViewController.m
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLCompletionViewController.h"

@interface LLCompletionViewController ()

@end

@implementation LLCompletionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) completionViewDismiss{
	[self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (IBAction)noneUIShareToSinaWeiboClickHandler:(UIButton *)sender
{
	//创建分享内容
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@""
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:NO
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	//创建分享选项
	/*id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil
	 oneKeyShareList:nil
	 qqButtonHidden:YES
	 wxSessionButtonHidden:YES
	 wxTimelineButtonHidden:YES
	 showKeyboardOnAppear:NO
	 shareViewDelegate:nil
	 friendsViewDelegate:nil
	 picViewerViewDelegate:nil];
	//创建分享列表
	NSArray *shareList = [ShareSDK customShareListWithType:SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),nil];
	*/
	
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeSinaWeibo
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
							 }
						 }];
	
}

/**
 *	@brief	分享到微信
 *
 *	@param 	sender 	事件对象
 */
- (IBAction)noneUIShareToWeiXinClickHandler:(UIButton *)sender
{
	//创建分享内容
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@""
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
   //定制微信朋友圈信息
	[publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:SSPublishContentMediaTypeImage]
													  content:INHERIT_VALUE
														 title:INHERIT_VALUE
															url:INHERIT_VALUE
														 image:INHERIT_VALUE
												musicFileUrl:nil
													  extInfo:nil
													 fileData:nil
												emoticonData:nil];

	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:NO
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	//创建分享选项
	/*id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil
	 oneKeyShareList:nil
	 qqButtonHidden:YES
	 wxSessionButtonHidden:YES
	 wxTimelineButtonHidden:YES
	 showKeyboardOnAppear:NO
	 shareViewDelegate:nil
	 friendsViewDelegate:nil
	 picViewerViewDelegate:nil];
	 //创建分享列表
	 NSArray *shareList = [ShareSDK customShareListWithType:SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),nil];
	 */
	
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeWeixiTimeline
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
							 }
						 }];
	
}

/**
 *	@brief	分享到豆瓣
 *
 *	@param 	sender 	事件对象
 */
- (IBAction)noneUIShareToDouBanClickHandler:(UIButton *)sender
{
	//创建分享内容
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@" "
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:NO
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	//创建分享选项
	/*id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil
	 oneKeyShareList:nil
	 qqButtonHidden:YES
	 wxSessionButtonHidden:YES
	 wxTimelineButtonHidden:YES
	 showKeyboardOnAppear:NO
	 shareViewDelegate:nil
	 friendsViewDelegate:nil
	 picViewerViewDelegate:nil];
	 //创建分享列表
	 NSArray *shareList = [ShareSDK customShareListWithType:SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),nil];
	 */
	
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeDouBan
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
							 }
						 }];
	
}

/**
 *	@brief	分享到人人网
 *
 *	@param 	sender 	事件对象
 */
- (IBAction)noneUIShareToRenrenClickHandler:(UIButton *)sender
{
	//创建分享内容
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@""
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
	//定制人人网信息
	[publishContent addRenRenUnitWithName:@""
									  description:INHERIT_VALUE
												 url:INHERIT_VALUE
											message:INHERIT_VALUE
											  image:INHERIT_VALUE
											caption:nil];
	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:NO
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	//创建分享选项
	/*id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil
	 oneKeyShareList:nil
	 qqButtonHidden:YES
	 wxSessionButtonHidden:YES
	 wxTimelineButtonHidden:YES
	 showKeyboardOnAppear:NO
	 shareViewDelegate:nil
	 friendsViewDelegate:nil
	 picViewerViewDelegate:nil];
	 //创建分享列表
	 NSArray *shareList = [ShareSDK customShareListWithType:SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),nil];
	 */
	
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeRenren
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
							 }
						 }];
	
}


@end
