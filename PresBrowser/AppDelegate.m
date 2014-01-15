//
//  AppDelegate.m
//  PresBrowser
//
//  Created by Oz Michaeli on 4/20/13.
//  Copyright (c) 2013 Oz Michaeli. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize secondWindow;
@synthesize webViewArea;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
	
	// Set up the UI
		
	UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(10,30, 300, 30)];
	input.backgroundColor = [UIColor whiteColor];
	input.autocapitalizationType = UITextAutocapitalizationTypeNone;
	input.keyboardType = UIKeyboardTypeURL;
	input.delegate = self;
	[self.window addSubview:input];
	
	// Use this to set focus on the input
//	[input becomeFirstResponder];
    
    //save the area the webview defaults to so we can move and resize it multiple times
    CGSize size = self.window.frame.size;
    webViewArea = CGRectMake(0, 70, size.width, size.height-70);
	mainWebView = [[UIWebView alloc] initWithFrame:webViewArea];
    mainWebView.scalesPageToFit = YES;
    mainWebView.contentMode = UIViewContentModeScaleToFill;
    mainWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainWebView.autoresizesSubviews = YES;
	[self.window addSubview:mainWebView];
	
	// Without this line, olark requests kill the airplay
	mainWebView.delegate = self;
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://oztune.github.io/chewy/"]]];
	

	// Set up the AirPlay code
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
				   name:UIScreenDidConnectNotification object:nil];
	[center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
				   name:UIScreenDidDisconnectNotification object:nil];
	
	if ([[UIScreen screens] count] > 1) {
		// Get the screen object that represents the external display.
		UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
		[self onScreen:secondScreen];
	}
	
	// Rendering timer
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
	
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:textField.text]]];
	
    return NO;
}

- (void) onScreen: (UIScreen *)screen {
	
	if (self.secondWindow) return;
	
	// These are the bounds of the external screen
	CGRect screenBounds = screen.applicationFrame;
	
	screen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
	// ROTATE the window
	// This code is wonky and should be redone
	CGRect windowBounds = CGRectMake(screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.height, screenBounds.size.width);
    UIWindow *window = [[UIWindow alloc] initWithFrame:windowBounds];
	window.center = CGPointMake(screenBounds.origin.x + screenBounds.size.width/2, screenBounds.origin.y + screenBounds.size.height/2);
	window.transform = CGAffineTransformRotate(window.transform, M_PI_2);
	
	////////////
	
	// Create an image inside the window so that we can draw
	// the web view into it.
	if (!imageView) {
		imageView = [[UIImageView alloc] initWithFrame:windowBounds];
	}
	[window addSubview:imageView];
	
    CGRect frame = mainWebView.frame;
    CGSize augmentedFrameSize = [self calculateScaleOf:windowBounds.size withMax:webViewArea.size];
    
    // resize view
    frame.size = augmentedFrameSize;
    [mainWebView setBounds:frame];
    
    // center it in parent
    frame.origin = [self center:augmentedFrameSize in:webViewArea];
    [mainWebView setFrame: frame];
    
	// Finish it
	
	window.screen = screen;
	window.backgroundColor = [UIColor orangeColor];
	window.hidden = NO;
	
	self.secondWindow = window;
}

- (CGSize) calculateScaleOf: (CGSize)other withMax: (CGSize) maxSize{
    float ratio = other.width / other.height;
    
    float attemptedWidth = ratio * maxSize.height;
    float attemptedHeight = maxSize.width / ratio;
    
    if(attemptedWidth > maxSize.width){
        attemptedWidth = maxSize.width;
        attemptedHeight = attemptedWidth / ratio;
    }
    
    if(attemptedHeight > maxSize.height){
        attemptedHeight = maxSize.height;
        attemptedWidth = ratio * attemptedHeight;
    }

    return CGSizeMake(attemptedWidth, attemptedHeight);
}

- (CGPoint) center: (CGSize) newSize in: (CGRect) space{
    float x = (space.size.width - newSize.width) / 2 + space.origin.x;
    float y = (space.size.height - newSize.height) / 2 + space.origin.y;
    return CGPointMake(x,y);
}

- (void)rescaleWebViewContent{
    [mainWebView setNeedsDisplay];
    [mainWebView setNeedsLayout];
}

- (void)onTick {
	if (!mainWebView) return;
	
	// Grab the web view and render its contents
	// to an image.
	
	UIView *view = mainWebView;
	
	// Note: the last param (scale) can be set to a high value (ie 2.0) to make the image sharper
	// or a low one (ie 0.5) to make the image blurrier.
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    
    // the underlying layer is the size of the initial frame
    // so we need to displace the graphics context
    // to the same origin
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -1 * webViewArea.origin.x, -1 * webViewArea.origin.y);
    
    //take the screenshot
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	imageView.image = img;
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
	[self onScreen:newScreen];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    if (self.secondWindow)
    {
        // Hide and then delete the window.
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

///
/// UIWebViewDelegate methods
///

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"1 Did fail");

    if (error.code == NSURLErrorCancelled) return;
    
	[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL.absoluteString rangeOfString:@"olark"].length > 0) return NO;
//	NSLog(@"2 %@, %i", request.URL.absoluteString, [request.URL.absoluteString rangeOfString:@"olark"].length > 0);
//	NSLog(@"2 Should load, %@, %i", request, navigationType);
	return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
//	NSLog(@"3 Did finish load");
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
//	NSLog(@"4 Did start load");
}

@end
