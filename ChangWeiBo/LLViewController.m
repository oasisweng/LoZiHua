//
//  LLViewController.m
//  changWeiBo
//
//  Created by Dingzhong Weng on 4/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLViewController.h"

@interface LLViewController ()

@end

@implementation LLViewController{
	BOOL hasBackUp;
	NSDictionary* systemProperty;
	
	BOOL currentBoldStatus;
	BOOL currentItalicStatus;
	BOOL currentUnderlineStatus;
	BOOL currentStrikeEnabled;
	
	//Variable declarations for Step 6
	int currentFontSize;
	
	//Variable declarations for Step 9
	BOOL currentUndoStatus;
	BOOL currentRedoStatus;
	
	//Variable declaration for Step 10
	//UIPopoverController *imagePickerPopover;
	FDTakeController* imagePickerController;
	
	
	//Variable declaration for Step 11
	CGPoint initialPointOfImage;
	
	//Variables for view management
	CGRect originalChangWeiBoFrame;
}

@synthesize changWeiBo = _changWeiBo;
@synthesize cvc = _cvc;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize optionsView = _optionsView;
@synthesize timer = _timer;
@synthesize colorPicker = _colorPicker;
@synthesize fontPicker = _fontPicker;
@synthesize imagePicker = _imagePicker;
@synthesize boldBtn = _boldBtn;
@synthesize italicBtn = _italicBtn;
@synthesize underlineBtn = _underlineBtn;
@synthesize fontUpBtn = _fontUpBtn;
@synthesize fontDownBtn = _fontDownBtn;
@synthesize highlightBtn = _highlightBtn;
@synthesize strikeBtn = _strikeBtn;
@synthesize redoBtn = _redoBtn;
@synthesize undoBtn = _undoBtn;
@synthesize doneBtn = _doneBtn;
@synthesize backUpSaveInterval = _backUpSaveInterval;

#pragma mark - Additions
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	
	// if the gesture recognizers are on different views, don't allow simultaneous recognition
	if (gestureRecognizer.view != otherGestureRecognizer.view)
		return NO;
	
	// if either of the gesture recognizers is the long press, don't allow simultaneous recognition
	if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
		return NO;
	
	return YES;
}

- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
	if ([rgb rangeOfString:@"rgb"].location == NSNotFound)
		return nil;
	
	NSMutableString *mutableCopy = [rgb mutableCopy];
	[mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
	[mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length-1, 1) withString:@""];
	
	NSArray *components = [mutableCopy componentsSeparatedByString:@","];
	int red = [[components objectAtIndex:0] intValue];
	int green = [[components objectAtIndex:1] intValue];
	int blue = [[components objectAtIndex:2] intValue];
	
	UIColor *retVal = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
	return retVal;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//Load nib file of _changweibo and optionsView
	[[NSBundle mainBundle]loadNibNamed:@"LLInputMethodAttachView" owner:self options:nil];
	[[NSBundle mainBundle]loadNibNamed:@"LLOptionsView" owner:self options:nil];
	
	//Load _completionviewcontroller(_cvc）
	_cvc = [[LLCompletionViewController alloc]initWithNibName:@"completionView" bundle:[NSBundle mainBundle]];
	_cvc.modalPresentationStyle = UIModalPresentationFormSheet;
	_cvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	
	//Step 1: Load template.html, if there is a back-up, load the back-up
	NSBundle *bundle = [NSBundle mainBundle];
	NSURL *propertyFileURL = [bundle URLForResource:@"systemProperty" withExtension:@"plist"];
	systemProperty = [NSDictionary dictionaryWithContentsOfURL:propertyFileURL];
	hasBackUp = [[systemProperty objectForKey:@"hasBackUp"]boolValue];
	
	NSURL *indexFileURL;
	if (hasBackUp){
		NSString *backUpPath = [systemProperty objectForKey:@"backUpFilePath"];
		indexFileURL = [NSURL URLWithString:backUpPath];
	} else
		indexFileURL = [bundle URLForResource:@"template" withExtension:@"html"];
	
	[_changWeiBo loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
	
	//Step 5: Replace codes from Step 2 with single function call
	[self checkSelection:self];
	
	//Step 3: Add Notification To Remove UIWebAccessoryView
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	//Step 4: Add checkSelection Methods To Validate Bar Buttons
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
	
	//Step 11: Moving images
	LLRTEGestureRecognizer *tapInterceptor = [[LLRTEGestureRecognizer alloc] init];
	tapInterceptor.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
		// Here we just get the location of the touch
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint touchPoint = [touch locationInView:_changWeiBo];
		
		// What we do here is to get the element that is located at the touch point to see whether or not it is an image
		NSString *javascript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).toString()", touchPoint.x, touchPoint.y];
		NSString *elementAtPoint = [_changWeiBo stringByEvaluatingJavaScriptFromString:javascript];
		
		if ([elementAtPoint rangeOfString:@"Image"].location != NSNotFound) {
			// We set the inital point of the image for use latter on when we actually move it
			initialPointOfImage = touchPoint;
			// In order to make moving the image easy we must disable scrolling otherwise the view will just scroll and prevent fully detecting movement on the image.
			
			//***This line is commented out also because of the suspension of moveImageTo function
			//_changWeiBo.scrollView.scrollEnabled = NO;
			
		} else {
			initialPointOfImage = CGPointZero;
		}
	};
	
	tapInterceptor.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
		// Let's get the finished touch point
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint touchPoint = [touch locationInView:_changWeiBo];
		
		//**Bug solution: Touch might be negative during scroll movement bug, we need to check the touch
		if (touchPoint.x>=0
			 &touchPoint.x<=_changWeiBo.frame.size.width
			 &touchPoint.y<=_changWeiBo.frame.size.height
			 &touchPoint.y>=0){
			// And move that image!
			//When we want to move Image around, it is very hard to scroll, at this moment, I have to disable this ability until we find a better way of doing it
			//NSString *javascript = [NSString stringWithFormat:@"moveImageAtTo(%f, %f, %f, %f)", initialPointOfImage.x, initialPointOfImage.y, touchPoint.x, touchPoint.y];
			//[_changWeiBo stringByEvaluatingJavaScriptFromString:javascript];
		}
		
		//_changWeiBo.scrollView.scrollEnabled = YES;
		
	};
	
	[_changWeiBo.scrollView addGestureRecognizer:tapInterceptor];
	
	//set proper size to _inputAccessoryView for correct display
	CGRect correctDisplayOfInputAccessoryViewFrame = _inputAccessoryView.frame;
	correctDisplayOfInputAccessoryViewFrame.origin.x = 0;
	correctDisplayOfInputAccessoryViewFrame.origin.y = 0;
	_inputAccessoryView.frame = correctDisplayOfInputAccessoryViewFrame;
	
	//store the original frame of _changWeiBo
	originalChangWeiBoFrame = _changWeiBo.frame;
	
	//disable bounces of the _changWeiBo
	_changWeiBo.scrollView.bounces = NO;
	
	//edit the background of self.view
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"viewFill.png"]];
	
	//edit the background of _optionView
	_inputAccessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"inputAccessoryFill.png"]];
	
	//edit the background of _optionView
	_optionsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"optionViewFill.png"]];
	
	//embellish the _changWeiBo so that it looks 3D
	_changWeiBo.layer.shadowColor = [[UIColor darkGrayColor]CGColor];
	_changWeiBo.layer.shadowOpacity = 0.9f;
	_changWeiBo.layer.shadowOffset = CGSizeMake(1, 1);
	
	//set time interval of every five minutes, auto save
	_backUpSaveInterval = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(saveContents) userInfo:nil repeats:YES];
	
	//localize doneBtn
	NSString* doneBtnNormalLocalizedImage = NSLocalizedString(@"doneBtn normal title path", @"doneBtn normal state title");
		NSString* doneBtnHighlightLocalizedImage = NSLocalizedString(@"doneBtn highlight title path", @"doneBtn highlight state title");
	[_doneBtn setImage:[UIImage imageNamed:doneBtnNormalLocalizedImage] forState:UIControlStateNormal];
	[_doneBtn setImage:[UIImage imageNamed:doneBtnHighlightLocalizedImage] forState:UIControlStateHighlighted];
	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma Web View Operation
// These methods are for Step 2
- (IBAction)setBold:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (IBAction)setItalic:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (IBAction)setUnderline:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
}

//These methods are for Step 12
- (IBAction)setStrike:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"strikeThrough\")"];
}

// These methods are for Step 3
- (void)keyboardWillShow:(NSNotification *)notification {
	NSLog(@"keyboardWillShow");
	[self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
	
	NSDictionary *userInfo = [notification userInfo];
	// Get the origin of the keyboard when it's displayed.
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
	// Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
	CGRect keyboardRect = [aValue CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	
	//Insert options view
	[self.view addSubview:_optionsView];
	CGRect inputOptionViewFrame = _optionsView.frame;
	inputOptionViewFrame.origin.x = 0;
	inputOptionViewFrame.origin.y = 0;
	_optionsView.frame = inputOptionViewFrame;
	
	//Determine the new position of _changWeiBo
	CGFloat keyboardTop = keyboardRect.origin.y;
	CGRect newWebViewFrame = originalChangWeiBoFrame;
	newWebViewFrame.origin.y = _optionsView.frame.size.height;
	newWebViewFrame.size.height = self.view.frame.size.height - keyboardTop - 20;
	
	// Get the duration of the animation.
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	
	// Animate the resize of the text view's frame in sync with the keyboard's appearance.
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[_changWeiBo setFrame:newWebViewFrame];
	
	[UIView commitAnimations];
	
	
}


- (void)keyboardWillHide:(NSNotification *)notification {
	/*
	 Restore the size of the text view (fill self's view).
	 Animate the resize so that it's in sync with the disappearance of the keyboard.
	 */
	
	[_optionsView removeFromSuperview];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_changWeiBo setFrame:originalChangWeiBoFrame];
	[UIView commitAnimations];
	
	NSLog(@"keyboardWillHide: %@,%@", NSStringFromCGRect(_changWeiBo.frame),NSStringFromCGRect(originalChangWeiBoFrame));
	
	//Scroll _changWeiBo to top
	[_changWeiBo.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	
}

- (void)removeBar {
	// Locate non-UIWindow.
	UIWindow *keyboardWindow = nil;
	for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
		if (![[testWindow class] isEqual:[UIWindow class]]) {
			keyboardWindow = testWindow;
			break;
		}
	}
	
	// Locate UIWebFormView.
	for (UIView *possibleFormView in [keyboardWindow subviews]) {
		// iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
		if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
			for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
				if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
					for (UIView* subview in [subviewWhichIsPossibleFormView subviews]){
						[subview removeFromSuperview];
					}
					[(UIToolbar*)subviewWhichIsPossibleFormView addSubview:_inputAccessoryView];
				}
			}
		}
	}
}

// These methods are for Step 4
- (void)checkSelection:(id)sender {
	
	//	UIMenuController *menuController = [UIMenuController sharedMenuController];
	//	if ([menuController isMenuVisible]&&[self becomeFirstResponder]){
	//		CGRect targetFrame = menuController.menuFrame;
	//		targetFrame.origin.y += 100;
	//		[menuController update];
	//		[menuController setTargetRect:targetFrame inView:_changWeiBo];
	//		[menuController setMenuVisible:YES animated:YES];
	//	}
	
	
	BOOL boldEnabled = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
	BOOL italicEnabled = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
	BOOL underlineEnabled = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
	BOOL strikeEnabled = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('StrikeThrough')"] boolValue];
	
	[_boldBtn setBackgroundImage:(boldEnabled)? [UIImage imageNamed:@"boldFaceH.png"]:[UIImage imageNamed:@"boldFace.png"] forState:UIControlStateNormal];
	[_italicBtn setBackgroundImage:(italicEnabled)? [UIImage imageNamed:@"italicFaceH.png"]:[UIImage imageNamed:@"italicFace.png"] forState:UIControlStateNormal];
	[_underlineBtn setBackgroundImage:(underlineEnabled)? [UIImage imageNamed:@"underlineFaceH.png"]:[UIImage imageNamed:@"underlineFace.png"] forState:UIControlStateNormal];
	[_strikeBtn setBackgroundImage:(strikeEnabled)? [UIImage imageNamed:@"strikeFaceH.png"]:[UIImage imageNamed:@"strikeFace.png"] forState:UIControlStateNormal];
	
	if (currentBoldStatus != boldEnabled || currentItalicStatus != italicEnabled || currentUnderlineStatus != underlineEnabled || currentStrikeEnabled || sender == self) {
		currentBoldStatus = boldEnabled;
		currentItalicStatus = italicEnabled;
		currentUnderlineStatus = underlineEnabled;
		currentStrikeEnabled = strikeEnabled;
	}
	
	//these lines of code are extended for Step 5
	NSString *currentColor = [_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
	BOOL isYellow = [currentColor isEqualToString:@"rgb(255, 255, 0)"];
	
	[_highlightBtn setBackgroundImage:(isYellow)? [UIImage imageNamed:@"highlightFaceH.png"]:[UIImage imageNamed:@"highlightFace.png"] forState:UIControlStateNormal];
	
	//Step 6: Allow user to interact with font size
	
	//*add the following code just before we add the bar button items to our array*
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue];
	if (size == 7)
		_fontUpBtn.enabled = NO;
	else
		_fontUpBtn.enabled = YES;
	if (size == 1)
		_fontDownBtn.enabled = NO;
	else
		_fontDownBtn.enabled = YES;
	
	//Step 7: Create Font Color Picker
	//	NSString *foreColor = [_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('foreColor')"];
	//	UIColor *color = [self colorFromRGBValue:foreColor];
	//	if (color)
	//		[_colorPicker setTintColor:color];
	
	//Step 8: Create Font Picker
	//	NSString *fontName = [_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontName')"];
	//	UIFont *font = [UIFont fontWithName:fontName size:[UIFont systemFontSize]];
	//	NSDictionary* strAttrs = [[NSDictionary alloc]initWithObjectsAndKeys:font,UITextAttributeFont, nil];
	//	NSAttributedString* str = [[NSAttributedString alloc]initWithString:@"F" attributes:strAttrs];
	//	if (font)
	//		 [_fontPicker setAttributedTitle:str forState:UIControlStateNormal];
	
	//Step 9: Redo and Undo
	//UIBarButtonItem *undo = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:self action:@selector(undo)];
	//UIBarButtonItem *redo = [[UIBarButtonItem alloc] initWithTitle:@"R" style:UIBarButtonItemStyleBordered target:self action:@selector(redo)];
	
	BOOL undoAvailable = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('undo')"] boolValue];
	BOOL redoAvailable = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('redo')"] boolValue];
	
	if (!undoAvailable)
		[_undoBtn setEnabled:NO];
	else
		[_undoBtn setEnabled:YES];
	
	if (!redoAvailable)
		[_redoBtn setEnabled:NO];
	else
		[_redoBtn setEnabled:YES];
	
	//Step 10: Insert images
	//Already did in the xib file
	
	//Step 8+: Replace if statement from Step 6 to the following lines
	//Step 9+: Replace if statement from Step 8+ to the following lines
	if (currentFontSize != size || currentUndoStatus != undoAvailable || currentRedoStatus != redoAvailable || sender == self) {
		currentFontSize = size;
		currentUndoStatus = undoAvailable;
		currentRedoStatus = redoAvailable;
	}
	
}

// These methods are for Step 5
- (IBAction)setHighlight:(id)sender {
	NSString *currentColor = [_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
	if ([currentColor isEqualToString:@"rgb(255, 255, 0)"]) {
		[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'white')"];
	} else {
		[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'yellow')"];
	}
}

// These methods are for Step 6
- (IBAction)fontUp:(id)sender {
	[timer invalidate]; // Stop it while we work
	
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

- (IBAction)fontDown:(id)sender {
	[timer invalidate]; // Stop it while we work
	
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

// These methods are for Step 7 & 8
- (IBAction)setFont:(id)sender {
	//change button view to indicate selection
	[_fontPicker setBackgroundImage:[UIImage imageNamed:@"fontPickH.png"] forState:UIControlStateNormal];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Helvetica", @"Courier", @"Arial", @"American Typewriter", @"Times New Roman", nil];
	[actionSheet showFromRect:((UIButton*)sender).frame inView:self.view animated:YES];
}

- (IBAction)setColor:(id)sender {
	//change button view to indicate selection
	[_colorPicker setBackgroundImage:[UIImage imageNamed:@"colorWheelH.png"] forState:UIControlStateNormal];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
	[actionSheet showFromRect:((UIButton*)sender).frame inView:self.view animated:YES];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	selectedButtonTitle = [selectedButtonTitle lowercaseString];
	
	if ([actionSheet.title isEqualToString:@"Select a font"]){
		//change button view to indicate selection
		[_fontPicker setBackgroundImage:[UIImage imageNamed:@"fontPick.png"] forState:UIControlStateNormal];
		
		[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
		NSLog(@"The font name is set to : %@",[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontName')"]);
	}	else {
		//change button view to indicate selection
		[_colorPicker setBackgroundImage:[UIImage imageNamed:@"colorWheel.png"] forState:UIControlStateNormal];
		
		[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
	}
}

//- (IBAction)setTextAlignment:(UIButton *)sender {}

// These methods are for Step 9
- (IBAction)redo:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
}

- (IBAction)undo:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
}

// These methods are for Step 10
- (IBAction)insertImage:(id)sender {
	//change button view to indicate selection
	[_imagePicker setBackgroundImage:[UIImage imageNamed:@"cameraIconH.png"] forState:UIControlStateNormal];
	
	imagePickerController = [[FDTakeController alloc]init];
	imagePickerController.delegate = self;
	imagePickerController.allowsEditingPhoto = YES;
	//[imagePickerController takePhotoOrChooseFromLibrary];
}

static int i = 0;

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info{
	NSLog(@"An image is inserted:");
	// Obtain the path to save to
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%i.png", i]];
	
	// Extract image from the picker and save it
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:@"public.image"]){
		UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
		UIImage *image = [[UIImage alloc]initWithCGImage:editedImage.CGImage scale:1.0 orientation:UIImageOrientationUp];
		
		// Save it to the camera roll / saved photo album
		BOOL isChosenFromLibrary = [(NSNumber*)[info objectForKey:@"isChosenFromLibrary"] boolValue];
		if (!isChosenFromLibrary){
			//when the image is shot in portrait, the image shot needs a 90 degree rotation.
			if (image.imageOrientation != UIImageOrientationUp){
				
			}
			
			//if it is derived from a camera shot
			UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		}
		
		CGFloat ratio = image.size.height/image.size.width;
		UIImage *scaledImage = [image scaleToSize:CGSizeMake(290.0f, 290.0f*ratio)];
		NSData *data = UIImagePNGRepresentation(scaledImage);
		//NSData *data = UIImagePNGRepresentation(image);
		[data writeToFile:imagePath atomically:YES];
		
		NSLog(@"%@ with info: %@ and orientation:%i",image, info,image.imageOrientation);
	}
	
	//allow me to programmatically bring up keyboard
	_changWeiBo.keyboardDisplayRequiresUserAction = NO;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').focus()"];
	
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('insertImage', false, '%@')", imagePath]];
	//allow me to programmatically bring up keyboard
	_changWeiBo.keyboardDisplayRequiresUserAction = YES;
	
	i++;
	
	//change button view to indicate selection
	[_imagePicker setBackgroundImage:[UIImage imageNamed:@"cameraIcon.png"] forState:UIControlStateNormal];
	
}

#pragma Completion Operation Methods
// These methods are defined to Oasis
- (IBAction) renderWebViewToImage
{
	UIImage* image = nil;
	
	//load the banner image
	UIImageView* supportImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"supportBanner.png"]];
	CGSize contentSize = _changWeiBo.scrollView.contentSize;
	CGRect bannerFrame = CGRectMake(0, contentSize.height, supportImage.frame.size.width, supportImage.frame.size.height);
	supportImage.frame = bannerFrame;
	[_changWeiBo.scrollView addSubview:supportImage];
	
	UIGraphicsBeginImageContext(_changWeiBo.scrollView.contentSize);
	{
		CGPoint savedContentOffset = _changWeiBo.scrollView.contentOffset;
		CGRect savedFrame = _changWeiBo.frame;
		
		_changWeiBo.scrollView.contentOffset = CGPointZero;
		_changWeiBo.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
		
		[_changWeiBo.layer renderInContext: UIGraphicsGetCurrentContext()];
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		_changWeiBo.scrollView.contentOffset = savedContentOffset;
		_changWeiBo.frame = savedFrame;
	}
	UIGraphicsEndImageContext();
	
	//remove the banner after its use
	[supportImage removeFromSuperview];
	
	if (image != nil) {
		NSString* storePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		NSString* imageFilePath = [storePath stringByAppendingPathComponent:@"savedChangWeiBo.png"];
		
		[UIImagePNGRepresentation(image) writeToFile: imageFilePath atomically: YES];
		
		// Save it to the camera roll / saved photo album
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		
		//we open the completion view when the file is saved successfully
		[self completionViewEnter:image];
		
		//then, we inform the app that the edit has been completed, delete backup file
		NSFileManager* defaultFileManager = [NSFileManager defaultManager];
		NSError* error = nil;
		NSString* backupPath = [systemProperty objectForKey:@"backUpFilePath"];
		if ([defaultFileManager fileExistsAtPath:backupPath])
			[defaultFileManager removeItemAtPath:backupPath error:&error];
		
		NSMutableDictionary* mutableSystemProperty = [systemProperty mutableCopy];
		[mutableSystemProperty setValue:nil forKey:@"backUpFilePath"];
		[mutableSystemProperty setValue:[NSNumber numberWithBool:NO] forKey:@"hasBackUp"];
		systemProperty = [mutableSystemProperty copy];
		NSBundle *bundle = [NSBundle mainBundle];
		NSURL *propertyFileURL = [bundle URLForResource:@"systemProperty" withExtension:@"plist"];
		[systemProperty writeToURL:propertyFileURL atomically:YES];
		
		[_backUpSaveInterval invalidate];
		
		
		//optional: this will only open in simulator
		//system("open ~/Documents/savedChangWeiBo.png");
	}
}

-(void)completionViewEnter:(UIImage *)imageToPass{
	[self addChildViewController:_cvc];
	_cvc.imageToPass = imageToPass;//pass the image for share purpose
	
	//present completion view modally using UIAnimation
	_cvc.view.center = self.view.center;
	CGRect frame = _cvc.view.frame;
	frame.origin.y = self.view.frame.size.height;
	_cvc.view.frame = frame;//set up initial frame
	_cvc.view.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
	_cvc.view.layer.shadowColor = [[UIColor grayColor]CGColor];
	_cvc.view.layer.shadowOpacity = 0.5;
	_cvc.view.layer.shadowRadius = 1.0f;
	_cvc.view.layer.borderColor = [[UIColor blackColor]CGColor];
	_cvc.view.layer.borderWidth = 1.0f;//set up shadow effect
	
	//enter the view
	[self.view addSubview:_cvc.view];
	[_cvc didMoveToParentViewController:self];
	
	//completion the animation(slide vertically til center in the screen)
	[UIView beginAnimations:@"Completion View Entering" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:1];
	_cvc.view.center = _changWeiBo.center;
	[UIView commitAnimations];
	
	[NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(completionViewDismissBufferZone) userInfo:nil repeats:NO];
	
}

-(void)completionViewDismissBufferZone{
	//we use a buffer zone to allow animation to be completed before the remove of cvc view
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(completionViewDismiss) userInfo:nil repeats:NO];
	
	//remove completion view modally using UIAnimation
	//completion the animation(slide vertically til center in the screen)
	[UIView beginAnimations:@"Completion View Entering" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:1];
	CGRect frame = _cvc.view.frame;
	frame.origin.y = self.view.frame.size.height;
	_cvc.view.frame = frame;//set up end frame
	[UIView commitAnimations];
}

-(void)completionViewDismiss{
	[_cvc willMoveToParentViewController:nil];
	[_cvc.view removeFromSuperview];
	[_cvc removeFromParentViewController];
}

- (void)saveContents {
	NSLog(@"checkPoints,sCBegin");
	//load the file path to save
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *savePath = [documentsDirectory stringByAppendingPathComponent:@"backup.html"];
	
	//get the html code from the webview
	NSString *jsToGetHTMLSource = @"document.documentElement.outerHTML";
	NSString *html = [_changWeiBo stringByEvaluatingJavaScriptFromString:
							jsToGetHTMLSource];
	
	//save the file
	NSError* error = nil;
	[html writeToFile:savePath atomically:YES encoding:NSASCIIStringEncoding error:&error];
	
	//update system property
	NSMutableDictionary* mutableSystemProperty = [systemProperty mutableCopy];
	[mutableSystemProperty setValue:savePath forKey:@"backUpFilePath"];
	[mutableSystemProperty setValue:[NSNumber numberWithBool:YES] forKey:@"hasBackUp"];
	systemProperty = [mutableSystemProperty copy];
	
	//save the plist
	NSBundle *bundle = [NSBundle mainBundle];
	NSURL *propertyFileURL = [bundle URLForResource:@"systemProperty" withExtension:@"plist"];
	[systemProperty writeToURL:propertyFileURL atomically:YES];
	
	NSLog(@"checkPoints,sCEnd");
}

- (IBAction)dismissWebViewKeyboard : (id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
	NSLog(@"orf %@",NSStringFromCGRect(originalChangWeiBoFrame));
}

@end