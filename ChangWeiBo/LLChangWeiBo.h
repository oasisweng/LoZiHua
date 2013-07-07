//
//  LLChangWeiBo.h
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 6/20/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJSON.h"
#import <QuartzCore/QuartzCore.h>


@interface LLChangWeiBo : UIWebView<UIWebViewDelegate>
@property (nonatomic,strong) NSNumber* imageWasDeleted;
@property (nonatomic,strong) UIImage* imageDeleted;

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args;
- (void)returnResult:(int)callbackId args:(id)firstObj, ...;

@end
