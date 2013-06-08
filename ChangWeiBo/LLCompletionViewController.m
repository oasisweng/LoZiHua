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
@synthesize promptMessage = _promptMessage;
@synthesize resultMessage = _resultMessage;
@synthesize imageToPass = _imageToPass;
@synthesize delegate;

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
	[_resultMessage setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) completionViewDismiss{
	[_resultMessage setHidden:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (IBAction)noneUIShareToSinaWeiboClickHandler:(UIButton *)sender
{
	
	[self.delegate completionViewWillShare];
	
	//创建分享内容
	NSString* imagePath = [self getImagePath];
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@"分享图片 来自Lo字画"
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeSinaWeibo
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 [self.delegate completionViewDidShare];
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
								 [self printSuccessfulMessage:ShareTypeSinaWeibo];
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
								 [self printFailedMessage:ShareTypeSinaWeibo andError:[error errorDescription]];
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
	[self.delegate completionViewWillShare];
	
	//创建分享内容
	NSString* imagePath = [self getImagePath];
	
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
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
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
							 [self.delegate completionViewDidShare];
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
								 [self printSuccessfulMessage:ShareTypeWeixiTimeline];
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
								 [self printFailedMessage:ShareTypeWeixiTimeline andError:[error errorDescription]];
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
	[self.delegate completionViewWillShare];
	
//	id<ISSDouBanApp> app = (id<ISSDouBanApp>)[ShareSDK getClientWithType:ShareTypeDouBan];
//	
//	//定制豆瓣网信息
//	SSDouBanErrorInfo* error = nil;
//	if ([app checkUnauthWithError:error]){
//		//如果没有授权，则授权，然后再发布
//		id<ISSAuthOptions> authOption = [ShareSDK authOptionsWithAutoAuth:YES
//																			 allowCallback:YES
//																			 authViewStyle:SSAuthViewStyleModal
//																			  viewDelegate:nil
//																authManagerViewDelegate:nil];
//		[ShareSDK authWithType:ShareTypeDouBan
//							options:authOption
//							 result:^(SSAuthState state, id<ICMErrorInfo> error) {
//								 if (!error)
//								 {
//									 NSLog(@"授权成功");
//								 }
//								 else
//								 {
//									 NSLog(@"授权失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
//								 }
//							 }];
//	}
	
	//创建分享内容
	NSString* imagePath = [self getImagePath];
	
	id<ISSContent> publishContent = [ShareSDK content:nil
												  defaultContent:@"分享图片 来自Lo字画"
															  image:[ShareSDK imageWithPath:imagePath]
															  title:nil
																 url:nil
													  description:nil
														 mediaType:SSPublishContentMediaTypeImage];
	
	//创建弹出菜单容器
	id<ISSContainer> container = [ShareSDK container];
	[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
	
	//创建授权选项
	id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
																		  allowCallback:YES
																		  authViewStyle:SSAuthViewStyleModal
																			viewDelegate:nil
															 authManagerViewDelegate:nil];
	//显示分享菜单
	[ShareSDK shareContent:publishContent
							type:ShareTypeDouBan
				  authOptions:authOptions
				statusBarTips:YES
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 [self.delegate completionViewDidShare];
							 if (state == SSPublishContentStateSuccess)
							 {
								 NSLog(@"发表成功");
								 [self printSuccessfulMessage:ShareTypeDouBan];
							 }
							 else if (state == SSPublishContentStateFail)
							 {
								 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
								 [self printFailedMessage:ShareTypeDouBan andError:[error errorDescription]];
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
	[self.delegate completionViewWillShare];
	
	id<ISSRenRenApp> app = (id<ISSRenRenApp>)[ShareSDK getClientWithType:ShareTypeRenren];
	
	//创建分享内容
	NSString* imagePath = [self getImagePath];
	id<ISSCAttachment> attachment = [ShareSDK imageWithPath:imagePath];
	NSLog(@"imagePath:%@, attachment solution:%@",imagePath,[attachment description]);
	
	//定制人人网信息
	SSRenRenErrorInfo* error = nil;
	if ([app checkUnauthWithError:error]){
		//如果没有授权，则授权，然后再发布
		id<ISSAuthOptions> authOption = [ShareSDK authOptionsWithAutoAuth:YES
																			 allowCallback:YES
																			 authViewStyle:SSAuthViewStyleModal
																			  viewDelegate:nil
																authManagerViewDelegate:nil];
		[ShareSDK authWithType:ShareTypeRenren
							options:authOption
							 result:^(SSAuthState state, id<ICMErrorInfo> error) {
								 if (!error)
								 {
									 NSLog(@"授权成功");
								 }
								 else
								 {
									 NSLog(@"授权失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
								 }
							 }];
	}
	
	if ([ShareSDK hasAuthorizedWithType:ShareTypeRenren])
		[app uploadPhoto:attachment caption:@"分享图片 来自长微博软件:Lo字画"
						 aid:0
					 result:^(BOOL result, SSRenRenPhoto *photo, SSRenRenErrorInfo *error) {
						 [self.delegate completionViewDidShare];
						 if (!error)
						 {
							 NSLog(@"发表成功");
							 [self printSuccessfulMessage:ShareTypeRenren];
						 }
						 else
						 {
							 NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
							 [self printFailedMessage:ShareTypeRenren andError:[error errorDescription]];
						 }
					 }];
	
}


-(NSString*)getImagePath{
	NSString* storePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	NSString* imageFilePath = [storePath stringByAppendingPathComponent:@"savedChangWeiBo.png"];
	
	return imageFilePath;
}

-(void)printSuccessfulMessage:(ShareType)shareType{
	NSString* successfulMSG;
	switch (shareType) {
		case ShareTypeRenren:
			successfulMSG =NSLocalizedString(@"result message share type renren", "completion view successful result message with share type");
			break;
		case ShareTypeSinaWeibo:
			successfulMSG =NSLocalizedString(@"result message share type weibo", "completion view successful result message with share type");
			break;
		case ShareTypeWeixiTimeline:
			successfulMSG =NSLocalizedString(@"result message share type weixin", "completion view successful result message with share type");
			break;
		case ShareTypeDouBan:
			successfulMSG =NSLocalizedString(@"result message share type douban", "completion view successful result message with share type");
			break;
		default:
			break;
	}
	[_resultMessage setHidden:NO];
	[_resultMessage setText:successfulMSG];
};

-(void)printFailedMessage:(ShareType)shareType andError:(NSString*)error{
	NSString* failedMSG;
	switch (shareType) {
		case ShareTypeRenren:
			failedMSG = [NSString stringWithFormat:NSLocalizedString(@"failed result message share type renren", "completion view failure result message with share type"),error];
			break;
		case ShareTypeSinaWeibo:
			failedMSG = [NSString stringWithFormat:NSLocalizedString(@"failed result message share type weibo", "completion view failure result message with share type"),error];
			break;
		case ShareTypeWeixiTimeline:
			failedMSG = [NSString stringWithFormat:NSLocalizedString(@"failed result message share type weixin", "completion view failure result message with share type"),error];
			break;
		case ShareTypeDouBan:
			failedMSG = [NSString stringWithFormat:NSLocalizedString(@"failed result message share type douban", "completion view failure result message with share type"),error];
			break;
		default:
			break;
	}
	[_resultMessage setHidden:NO];
	[_resultMessage setText:failedMSG];
};

@end
