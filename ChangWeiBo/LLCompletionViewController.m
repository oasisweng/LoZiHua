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
@synthesize promptMessageFirst = _promptMessageFirst;
@synthesize promptMessageSecond = _promptMessageSecond;
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

- (void)viewWillAppear:(BOOL)animated{
	[_resultMessage setHidden:YES];
	[_resultMessage setText:@""];
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Localize prompt title
	NSAttributedString* firstAttrStr = _promptMessageFirst.attributedText;
	NSDictionary* firstAttributes = [self iterateAttributesForString:firstAttrStr];
	NSString*firstLinePrompt = NSLocalizedString(@"successful save first line", @"Prompt of successful save First line");
	
	NSAttributedString* secondAttrStr = _promptMessageSecond.attributedText;
	NSDictionary* secondAttributes = [self iterateAttributesForString:secondAttrStr];
	NSString* secondLinePrompt = NSLocalizedString(@"successful save second line", @"Prompt of successful save Second Line");
	
	_promptMessageFirst.attributedText = [[NSAttributedString alloc]initWithString:firstLinePrompt attributes:firstAttributes];
	_promptMessageSecond.attributedText = [[NSAttributedString alloc]initWithString:secondLinePrompt attributes:secondAttributes];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma Miscs
- (NSDictionary*)iterateAttributesForString: (NSAttributedString *) string  {
	NSDictionary *attributeDict;
	NSRange effectiveRange = { 0, 0 };
	NSRange range;
	range = NSMakeRange (NSMaxRange(effectiveRange),
								[string length] - NSMaxRange(effectiveRange));
	attributeDict = [string attributesAtIndex: range.location
							  longestEffectiveRange: &effectiveRange
												 inRange: range];
	NSLog (@"Range: %@  Attributes: %@",
			 NSStringFromRange(effectiveRange), attributeDict);
	
	return attributeDict;
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
				statusBarTips:NO
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state != SSPublishContentStateBegan){
								 [self.delegate completionViewDidShare];
							 } else {
								 [self printUploadingMessage];
							 }
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
				statusBarTips:NO
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state != SSPublishContentStateBegan){
								 [self.delegate completionViewDidShare];
							 } else {
								 [self printUploadingMessage];
							 }
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
				statusBarTips:NO
						 result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
							 if (state != SSPublishContentStateBegan){
								 [self.delegate completionViewDidShare];
							 } else {
								 [self printUploadingMessage];
							 }
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
								 if (!error && state == SSAuthStateSuccess)
								 {
									 NSLog(@"授权成功");
								 }
								 else if (state == SSAuthStateFail || state == SSAuthStateCancel)
								 {
									 [self.delegate completionViewDidShare];
									 NSLog(@"授权失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
									 [self printFailedMessage:ShareTypeRenren andError:[error errorDescription]];
								 }
							 }];
	}
	
	if ([ShareSDK hasAuthorizedWithType:ShareTypeRenren]){
		[self printUploadingMessage];
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

-(void)printUploadingMessage{
	NSString* uploadingMSG = NSLocalizedString(@"uploading message", @"completion view uploading prompt");
	[_resultMessage setHidden:NO];
	[_resultMessage setText:uploadingMSG];
}

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
