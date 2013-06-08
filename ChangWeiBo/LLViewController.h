//
//  LLViewController.h
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LLCompletionViewController.h"
#import "UIImage+Resize.h"
#import "RTEGestureRecognizer.h"
#import "FDTakeController.h"

#define LLCoreTextAlignmentLeft 1
#define LLCoreTextAlignmentMid 2
#define LLCoreTextAlignmentRight 3
#define BackUpFileName @"backup.html"

@interface LLViewController : UIViewController<UIActionSheetDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,FDTakeDelegate,LLCompletionDelegate>{
	NSTimer *timer;
}

@property (strong, nonatomic) IBOutlet UIWebView *changWeiBo;
@property (strong, nonatomic) LLCompletionViewController* cvc;
@property (strong, nonatomic) NSTimer* timer;

// Input Accessory View Catagory
@property (strong, nonatomic) IBOutlet UIView * inputAccessoryView;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet UIButton *colorPicker;
@property (strong, nonatomic) IBOutlet UIButton *fontPicker;
@property (strong, nonatomic) IBOutlet UIButton *imagePicker;
@property (strong, nonatomic) IBOutlet UIButton *boldBtn;
@property (strong, nonatomic) IBOutlet UIButton *italicBtn;
@property (strong, nonatomic) IBOutlet UIButton *strikeBtn;
@property (strong, nonatomic) IBOutlet UIButton *highlightBtn;
@property (strong, nonatomic) IBOutlet UIButton *underlineBtn;
@property (strong, nonatomic) IBOutlet UIButton *fontUpBtn;
@property (strong, nonatomic) IBOutlet UIButton *fontDownBtn;
@property (strong, nonatomic) IBOutlet UIButton *completeBtn;
@property (strong, nonatomic) IBOutlet UIButton *undoBtn;
@property (strong, nonatomic) IBOutlet UIButton *redoBtn;
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@property (strong, nonatomic) UIImageView *supportImage;
@property (strong, nonatomic) NSTimer* backUpSaveInterval;
@property (strong, nonatomic) NSTimer* cVDBZTimer;

//main
- (CGSize)findActualSizeOfWebView;
- (IBAction)renderWebViewToImage;
- (void)completionViewEnter:(UIImage*)imageToPass;
- (void)completionViewDismissBufferZone;
- (void)completionViewDismiss;
- (void)saveContents;
//input accesorry view
- (IBAction)setFont:(id)sender;
- (IBAction)setColor:(id)sender;
- (IBAction)insertImage:(id)sender;
//- (IBAction)setTextAlignment:(UIButton *)sender;
- (IBAction)setBold:(id)sender;
- (IBAction)setItalic:(id)sender;
- (IBAction)setUnderline:(id)sender;
- (IBAction)fontUp:(id)sender;
- (IBAction)fontDown:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)setStrike:(id)sender;
- (IBAction)setHighlight:(id)sender;
- (IBAction)dismissWebViewKeyboard : (id)sender;

//notifications
- (void)menuWillShow:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end
