//
//  LLRTEGestureRecognizer.m
//  RichTextEditorPractice
//
//  Created by Dingzhong Weng on 4/27/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "RTEGestureRecognizer.h"

@implementation RTEGestureRecognizer
@synthesize touchesMovedCallback;
@synthesize touchesEndedCallback;
@synthesize touchesBeganCallback;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if (touchesBeganCallback)
		touchesBeganCallback(touches, event);
	else
		[super touchesBegan:touches withEvent:event];
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (touchesMovedCallback)
		touchesMovedCallback(touches, event);
	else
		[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if  (touchesEndedCallback)
		touchesEndedCallback(touches, event);
	else
		[super touchesEnded:touches withEvent:event];
}

@end
