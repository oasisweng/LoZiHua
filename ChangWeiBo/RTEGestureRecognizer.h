//
//  LLRTEGestureRecognizer.h
//  RichTextEditorPractice
//
//  Created by Dingzhong Weng on 4/27/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef void (^TouchEventBlock)(NSSet * touches, UIEvent * event);

@interface RTEGestureRecognizer : UILongPressGestureRecognizer {
	TouchEventBlock touchesMovedCallback;
	TouchEventBlock touchesEndedCallback;
	TouchEventBlock touchesBeganCallback;
}
@property(copy) TouchEventBlock touchesMovedCallback;
@property(copy) TouchEventBlock touchesEndedCallback;
@property(copy) TouchEventBlock touchesBeganCallback;

@end
