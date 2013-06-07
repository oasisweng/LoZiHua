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

@interface LLRTEGestureRecognizer : UIGestureRecognizer {
	TouchEventBlock touchesBeganCallback;
	TouchEventBlock touchesEndedCallback;
}
@property(copy) TouchEventBlock touchesBeganCallback;
@property(copy) TouchEventBlock touchesEndedCallback;
@end
