//
//  LLCompletionViewController.h
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>


@interface LLCompletionViewController : UIViewController
@property (strong, nonatomic) UIImage* imageToPass;

- (IBAction)noneUIShareToSinaWeiboClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToWeiXinClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToDouBanClickHandler:(UIButton *)sender;
- (IBAction)noneUIShareToRenrenClickHandler:(UIButton *)sender;
- (void)completionViewDismiss;

@end

