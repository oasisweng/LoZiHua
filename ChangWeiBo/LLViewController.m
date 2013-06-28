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
	BOOL shouldBackUp;
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
	UIImagePickerController *imagePicker;
	NSMutableArray* sources;
	NSMutableArray *buttonTitles;
	
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
@synthesize imagePickerBtn = _imagePickerBtn;
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
@synthesize supportImage = _supportImage;
@synthesize cVDBZTimer = _cVDBZTimer;
@synthesize popOverPresentRect = _popOverPresentRect;

#pragma mark - Additions

- (CGRect)popOverPresentRect
{
	if (_popOverPresentRect.size.height == 0 || _popOverPresentRect.size.width == 0)
		// See https://github.com/hborders/MGSplitViewController/commit/9247c81d6b8c9ad183f67ad01384a76302ed7f0b
		// on iOS 5.1, passing a CGRectZero here produces this following ominous message:
		// -[UIPopoverController presentPopoverFromRect:inView:permittedArrowDirections:animated:]: the rect passed in to this method must have non-zero width and height. This will be an exception in a future release.
		// this workaround was tested thusly:
		// On iOS 4.3, CGRectZero leaves a popover afterimage before rotation, so does the code below
		// On iOS 5.0, CGRectZero leaves a popover afterimage before rotation, the code below does not
		// On iOS 5.1, CGRectZero leaves a popover afterimage before rotation, so does the code below
		// Basically, this hack performs slightly better than the CGRectZero hack, and does not cause an ominous warning.
		_popOverPresentRect = CGRectMake(0, 0, 1, 1);
	return _popOverPresentRect;
}

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
	
	//initialize _changWeiBo;
	//_changWeiBo = [[LLChangWeiBo alloc]init];
	
	//Load _completionviewcontroller(_cvc）
	_cvc = [[LLCompletionViewController alloc]initWithNibName:@"completionView" bundle:[NSBundle mainBundle]];
	_cvc.modalPresentationStyle = UIModalPresentationFormSheet;
	_cvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	_cvc.delegate = self;
	
	
	//Step 1: Load template.html, if there is a back-up, load the back-up
	NSBundle *bundle = [NSBundle mainBundle];
	NSURL *propertyFileURL = [bundle URLForResource:@"systemProperty" withExtension:@"plist"];
	systemProperty = [NSDictionary dictionaryWithContentsOfURL:propertyFileURL];
	hasBackUp = [[systemProperty objectForKey:@"hasBackUp"]boolValue];
	shouldBackUp = [[systemProperty objectForKey:@"shouldBackUp"]boolValue];
	
	//load the back up if has one
	NSURL *indexFileURL;
	if (hasBackUp){
		NSString *backUpPath = [systemProperty objectForKey:@"backUpFilePath"];
		indexFileURL = [NSURL URLWithString:backUpPath];
	} else
		indexFileURL = [bundle URLForResource:@"template" withExtension:@"html"];
	
	[_changWeiBo loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
	
	//save contents every five minutes
	if (shouldBackUp){
		_backUpSaveInterval = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(saveContents) userInfo:nil repeats:YES];
	}
	
	//Step 5: Replace codes from Step 2 with single function call
	[self checkSelection:self];
	
	//Step 3: Add Notification To Remove UIWebAccessoryView
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
	
	//Step 4: Add checkSelection Methods To Validate Bar Buttons
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
	
	//Step 11: Moving images
	RTEGestureRecognizer *tapInterceptor = [[RTEGestureRecognizer alloc] init];	
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
			_changWeiBo.scrollView.scrollEnabled = NO;
		} else {
			initialPointOfImage = CGPointZero;
		}
	};
	tapInterceptor.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
		// Let's get the finished touch point
		UITouch *touch = [[event allTouches] anyObject];
		CGPoint touchPoint = [touch locationInView:self.view];
		
		// And move that image!
		if (touchPoint.x>=0
			 &touchPoint.x<=_changWeiBo.frame.size.width
			 &touchPoint.y<=_changWeiBo.frame.size.height
			 &touchPoint.y>=0){
		NSString *javascript = [NSString stringWithFormat:@"moveImageAtTo(%f, %f, %f, %f)", initialPointOfImage.x, initialPointOfImage.y, touchPoint.x, touchPoint.y];
		[_changWeiBo stringByEvaluatingJavaScriptFromString:javascript];
		}
		
		// All done, lets re-enable scrolling
		_changWeiBo.scrollView.scrollEnabled = YES;
	};
	
	[_changWeiBo.scrollView addGestureRecognizer:tapInterceptor];
	
	//set proper size to _inputAccessoryView for correct display
	CGRect correctDisplayOfInputAccessoryViewFrame = _inputAccessoryView.frame;
	correctDisplayOfInputAccessoryViewFrame.origin.x = 0;
	correctDisplayOfInputAccessoryViewFrame.origin.y = 0;
	_inputAccessoryView.frame = correctDisplayOfInputAccessoryViewFrame;
	
	//store the original frame of _changWeiBo
	originalChangWeiBoFrame = _changWeiBo.frame;
	
	//edit the background of self.view
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"viewFill.png"]];
	
	//edit the background of _inputAccessoryView
	_inputAccessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"inputAccessoryFill.png"]];
	
	//edit the background of _optionView
	_optionsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"optionViewFill.png"]];
	
	
	
	//edit the tile of _doneBtn
	NSString* doneBtnNormalLocalizedImage = NSLocalizedString(@"doneBtn normal title path", @"doneBtn normal state title");
	NSString* doneBtnHighlightLocalizedImage = NSLocalizedString(@"doneBtn highlight title path", @"doneBtn highlight state title");
	[_doneBtn setImage:[UIImage imageNamed:doneBtnNormalLocalizedImage] forState:UIControlStateNormal];
	[_doneBtn setImage:[UIImage imageNamed:doneBtnHighlightLocalizedImage] forState:UIControlStateHighlighted];
	
	//init support image
	_supportImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"supportBannerBig.JPG"]];
	
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
- (void)menuWillShow:(NSNotification *)notification{
	UIMenuController* menuController = [UIMenuController sharedMenuController];
	menuController.arrowDirection = UIMenuControllerArrowUp;
	NSLog(@"mC: arrow dir %i",menuController.arrowDirection);
	//[menuController setMenuVisible:YES animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	// add customized accessory bar
	[self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
	
	// get keyboard frame
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [aValue CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	NSLog(@"kR: %@",NSStringFromCGRect(keyboardRect));
	
	// insert options view
	[self.view addSubview:_optionsView];
	CGRect inputOptionViewFrame = _optionsView.frame;
	inputOptionViewFrame.origin.x = 0;
	inputOptionViewFrame.origin.y = 0;
	_optionsView.frame = inputOptionViewFrame;
	
	// determine the new position of _changWeiBo
	CGFloat keyboardTop = keyboardRect.origin.y;
	CGRect newWebViewFrame = originalChangWeiBoFrame;
	newWebViewFrame.origin.y = _optionsView.frame.size.height;
	newWebViewFrame.size.height = keyboardTop - newWebViewFrame.origin.y;
	
	// resize _changWeiBo
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL];
	{
		[UIView setAnimationDuration:animationDuration];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[_changWeiBo setFrame:newWebViewFrame];
	}
	[UIView commitAnimations];
	NSLog(@"keyboardWillShow, %@", NSStringFromCGRect(_changWeiBo.frame));
}

- (void)keyboardWillHide:(NSNotification *)notification {
	//remove option view
	[_optionsView removeFromSuperview];
	
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"insertLineBreak()"];
	
	//restore _changWeiBo
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[_changWeiBo setFrame:originalChangWeiBoFrame];
	[UIView commitAnimations];
	NSLog(@"keyboardWillHide: %@", NSStringFromCGRect(_changWeiBo.frame));
	
	//Scroll _changWeiBo to top
	//[_changWeiBo.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
	
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
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue];
	if (size == 7)
		_fontUpBtn.enabled = NO;
	else
		_fontUpBtn.enabled = YES;
	if (size == 1)
		_fontDownBtn.enabled = NO;
	else
		_fontDownBtn.enabled = YES;
	
	// undo and redo
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
	
	//update current selection status
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
- (void)correctHighlight{
	[self setHighlight:nil];
	[self setHighlight:nil];
}

- (IBAction)fontUp:(id)sender {
	[timer invalidate]; // Stop it while we work
	
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
	
	//if selection is highlighted, correct highlight
	[self correctHighlight];
}

- (IBAction)fontDown:(id)sender {
	[timer invalidate]; // Stop it while we work
	
	int size = [[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
	
	//if selection is highlighted, correct highlight
	[self correctHighlight];
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
	}	else if ([actionSheet.title isEqualToString:@"Select a font color"]){
		//change button view to indicate selection
		[_colorPicker setBackgroundImage:[UIImage imageNamed:@"colorWheel.png"] forState:UIControlStateNormal];
		
		[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
	} else if ([actionSheet.title isEqualToString:NSLocalizedString(@"choose a method", @"Prompt to choose photo options")]) {
		if (buttonIndex != actionSheet.cancelButtonIndex) {
			
			imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.sourceType = [[sources objectAtIndex:buttonIndex] integerValue];
			imagePicker.delegate = self;
			imagePicker.allowsEditing = YES;
			
			UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
			[vc presentViewController:imagePicker animated:YES completion:nil];
		}
		
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
static int i = 0;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	_changWeiBo.keyboardDisplayRequiresUserAction = NO;
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').focus()"];
	_changWeiBo.keyboardDisplayRequiresUserAction = YES;
	
	// Obtain the path to save to
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%i.png", i]];
	
	NSAssert([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage], @"Unhandled type: %@", [info objectForKey:UIImagePickerControllerMediaType]);
	
	UIImage* img = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
	CGFloat ratio = img.size.height/img.size.width;
	UIImage *scaledImage = [img scaleToSize:CGSizeMake(290.0f, 290.0f*ratio)];
	NSData *data = UIImagePNGRepresentation(scaledImage);
	[data writeToFile:imagePath atomically:YES];
	[_changWeiBo stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"insertImage('%@')",imagePath]];
	i++;
	
	NSLog(@"An image is inserted.");
	
}

- (void)setUpInsertImageActionSheet {
	//set up action sheet
	sources = [[NSMutableArray alloc]init];
	buttonTitles = [[NSMutableArray alloc]init];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypeCamera]];
		[buttonTitles addObject:NSLocalizedString(@"takePhoto", @"Option to take photo using camera")];
	}
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		[sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypePhotoLibrary]];
		[buttonTitles addObject:NSLocalizedString(@"chooseFromLibrary", @"Option to select photo/video from library")];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
		[sources addObject:[NSNumber numberWithInteger:UIImagePickerControllerSourceTypeSavedPhotosAlbum]];
		[buttonTitles addObject:NSLocalizedString(@"chooseFromPhotoRoll", @"Option to select photo from photo roll")];
	}
	
	NSLog(@"sources:%@",sources);
	if ([sources count]) {
		UIActionSheet* actionSheet = [[UIActionSheet alloc]
												initWithTitle:NSLocalizedString(@"choose a method", @"Prompt to choose photo options")
												delegate:self
												cancelButtonTitle:nil
												destructiveButtonTitle:nil
												otherButtonTitles:nil];
		for (NSString *title in buttonTitles)
			[actionSheet addButtonWithTitle:title];
		[actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", @"Decline to proceed with operation")];
		actionSheet.cancelButtonIndex = sources.count;
		
		// If on iPad use the present rect and pop over style.
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[actionSheet showFromRect:self.popOverPresentRect inView:[self presentingViewController].view animated:YES];
		}
		else {
			// Otherwise use iPhone style action sheet presentation.
			[actionSheet showInView:self.view];
		}
		
	} else {
		NSString *str = NSLocalizedString(@"noSources", @"There are no sources available to select a photo");
		[[[UIAlertView alloc] initWithTitle:nil
											 message:str
											delegate:self
								cancelButtonTitle:@"cancel"
								otherButtonTitles:nil] show];
	}
}

- (IBAction)insertImage:(id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"prepareInsertImage()"];
	
	[self setUpInsertImageActionSheet];
	
	//change button view to indicate selection
	[_imagePickerBtn setBackgroundImage:[UIImage imageNamed:@"cameraIcon.png"] forState:UIControlStateNormal];
}

#pragma Completion Operation Methods
// These methods are defined to Oasis
- (CGSize)findActualSizeOfWebView{
	CGSize actualSize;
	//Change changeWeiBo height to 1 px
	CGRect tempFrame = _changWeiBo.frame;
	tempFrame.size.height = 1;
	_changWeiBo.frame = tempFrame;
	
	//Calculate the actual content size
	actualSize = _changWeiBo.scrollView.contentSize;
	
	//insert the brand banner
	CGRect bannerFrame = CGRectMake(0, actualSize.height, 306.0f, 95.65f);
	_supportImage.frame = bannerFrame;
	[_changWeiBo addSubview:_supportImage];
	
	//Re-Calculate the actual size to collaborate with new support image
	actualSize.height += _supportImage.frame.size.height;
	
	//Restore the frame to its origin
	_changWeiBo.frame = originalChangWeiBoFrame;
	
	return actualSize;
}

- (IBAction) renderWebViewToImage
{
	UIImage* image = nil;
	CGSize contentSize = [self findActualSizeOfWebView];
	
	//contentSize changes, contentSize re-value
	contentSize = [self findActualSizeOfWebView];
	
	NSLog(@"cS:%@ oS:%@",NSStringFromCGSize(contentSize),NSStringFromCGSize(_changWeiBo.frame.size));
	
	UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0.0);
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
	[_supportImage removeFromSuperview];
	if (image != nil) {
		NSString* storePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		
		//Save the image as png format
		NSString* imageFilePath = [storePath stringByAppendingPathComponent:@"savedChangWeiBo.png"];
		[UIImagePNGRepresentation(image) writeToFile:imageFilePath atomically:YES];
		
		// Save it to the camera roll / saved photo album
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
		
		//we open the completion view when the file is saved successfully
		[self completionViewEnter:image];
		
		//Also, disable _changWeiBo
		[_changWeiBo setUserInteractionEnabled:NO];
		
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
	
	_cVDBZTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(completionViewDismissBufferZone) userInfo:nil repeats:NO];
	
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
	
	//Also, re-enable _changWeiBo
	[_changWeiBo setUserInteractionEnabled:YES];
}


-(void)completionViewWillShare{
	[_cVDBZTimer invalidate];
	NSLog(@"completionViewWillShare: timer invalidated.");
}

-(void)completionViewDidShare{
	_cVDBZTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(completionViewDismissBufferZone) userInfo:nil repeats:NO];
	NSLog(@"completionViewDidShare: timer reinstalled.");
	
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

- (IBAction)insertHorizontalRule:(id)sender{
	NSString* js =@"insertHorizontalRule()";
	[_changWeiBo stringByEvaluatingJavaScriptFromString:js];
}

- (IBAction)dismissWebViewKeyboard : (id)sender {
	[_changWeiBo stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
}

@end