//
//  LLUIImage+Resize.m
//  RichTextEditorPractice
//
//  Created by Dingzhong Weng on 4/28/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "UIImage+Resize.h"

// Put this in UIImageResizing.m
@implementation UIImage (Resize)

- (UIImage*)scaleToSize:(CGSize)size {
	//Only resize the image if the original picture is bigger than the screen
	if (self.size.width<size.width)
		size.width = self.size.width;
	else if (self.size.height<size.height)
		size.height = self.size.height;
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

@end
