//
//  UIWebBrowserView+Additions.m
//  RichTextEditor
//
//  Created by Joshua Garnham on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIWebBrowserView+Additions.h"

@implementation UIWebView (Additions)

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	//NSLog(@"check action %@, and sender %@", NSStringFromSelector(action), sender);
	
	//In the future, if we ever need to disable text option menu, we can use this line of code
	//|| action == @selector(_showTextStyleOptions:)
	
	if (action == @selector(_promptForReplace:) || action == @selector(_define:))
		return NO;
    return [super canPerformAction:action withSender:sender];
}

@end