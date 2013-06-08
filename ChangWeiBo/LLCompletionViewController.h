//
//  LLCompletionViewController.h
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import <RenRenConnection/ISSRenRenApp.h>
#import <DouBanConnection/ISSDouBanApp.h>

@protocol LLCompletionDelegate;

@interface LLCompletionViewController : UIViewController
@property (strong, nonatomic) UIImage* imageToPass;
@property (strong, nonatomic) id<LLCompletionDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *promptMessage;
@property (strong, nonatomic) IBOutlet UILabel *resultMessage;

- (IBAction)noneUIShareToSinaWeiboClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToWeiXinClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToDouBanClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToRenrenClickHandler:(UIButton *)sender;
- (void)completionViewDismiss;

-(NSString*)getImagePath;
-(void)printSuccessfulMessage:(ShareType)shareType;
-(void)printFailedMessage:(ShareType)shareType andError:(NSString*)error;

@end

@protocol LLCompletionDelegate <NSObject>

-(void)completionViewWillShare;
-(void)completionViewDidShare;

@end
