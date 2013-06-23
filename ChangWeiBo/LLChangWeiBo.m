//
//  LLChangWeiBo.m
//  ChangWeiBo
//
//  Created by Dingzhong Weng on 6/20/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLChangWeiBo.h"

@implementation LLChangWeiBo{
	//Variables for storing the caret position
	SBJSON *json;
	int alertCallbackId;

}

@synthesize caretPosEnd;
@synthesize caretPosStart;

- (id)init{
	self = [super init];
	if (self){
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		 json = [SBJSON new];
		 self.delegate = self;
		 self.layer.shadowColor = [[UIColor darkGrayColor]CGColor];
		 self.layer.shadowOpacity = 0.9f;
		 self.layer.shadowOffset = CGSizeMake(1, 1);
		 self.scrollView.bounces = NO;
    }
    return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSURL* url = request.URL;
	NSString* result = [url absoluteString];
	NSLog(@"webview result: %@",result);
	
	if ([result hasPrefix:@"js-frame:"]) {
		
		NSArray *components = [result componentsSeparatedByString:@":"];
		
		NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
		NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSArray *args = (NSArray*)[json objectWithString:argsAsString error:nil];
		[self handleCall:function callbackId:callbackId args:args];
		
		return NO;
	}
	
	return YES;
}

// Call this function when you have results to send back to javascript callbacks
// callbackId : int comes from handleCall function
// args: list of objects to send to the javascript callback
- (void)returnResult:(int)callbackId args:(id)arg, ...;
{
	if (callbackId==0) return;
	
	va_list argsList;
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	
	if(arg != nil){
		[resultArray addObject:arg];
		va_start(argsList, arg);
		while((arg = va_arg(argsList, id)) != nil)
			[resultArray addObject:arg];
		va_end(argsList);
	}
	
	NSString *resultArrayString = [json stringWithObject:resultArray allowScalar:YES error:nil];
	
	// We need to perform selector with afterDelay 0 in order to avoid weird recursion stop
	// when calling NativeBridge in a recursion more then 200 times :s (fails ont 201th calls!!!)
	[self performSelector:@selector(returnResultAfterDelay:) withObject:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,resultArrayString] afterDelay:0];
}

-(void)returnResultAfterDelay:(NSString*)str {
	// Now perform this selector with waitUntilDone:NO in order to get a huge speed boost! (about 3x faster on simulator!!!)
	[self performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
}

// Implements all your native function in this one, by matching 'functionName' and parsing 'args'
// Use 'callbackId' with 'returnResult' selector when you get some results to send back to javascript
- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
	// [self returnResult:callbackId args:nil];
	//	var t = document.getElementById("content");
	//	var sel = getInputSelection(t);
	//	setInputSelection(t, sel.start, sel.end);
	
	if ([functionName isEqualToString:@"storeCaretPosition"]) {
		caretPosStart = [(NSNumber*)[args objectAtIndex:0] copy];
		caretPosEnd= [(NSNumber*)[args objectAtIndex:1] copy];
		NSLog(@"caret pos is [%i,%i]",caretPosStart.integerValue,caretPosEnd.integerValue);
	} else if ([functionName isEqualToString:@"setCaretPosition"]) {
		NSNumber* start = [(NSNumber*)[args objectAtIndex:0] copy];
		NSNumber* end= [(NSNumber*)[args objectAtIndex:1] copy];
		NSLog(@"caret pos is set to [%i,%i]",start.integerValue,end.integerValue);
	} else {
		NSLog(@"Unimplemented method '%@'",functionName);
	}
}

@end
