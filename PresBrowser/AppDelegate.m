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
	
	mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 70, 300, 300)];
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
	CGRect screenBounds = screen.bounds;
	
	screen.overscanCompensation = UIScreenOverscanCompensationScale;
	
	UIWindow *window = [[UIWindow alloc] init];
	// ROTATE the window
	// This code is wonky and should be redone
	CGRect windowBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
	
	window.frame = windowBounds;
	window.center = CGPointMake(screenBounds.origin.x + screenBounds.size.width/2, screenBounds.origin.y + screenBounds.size.height/2);
	window.transform = CGAffineTransformRotate(window.transform, M_PI_2);
	
	////////////
	
	// Create an image inside the window so that we can draw
	// the web view into it.
	if (!imageView) {
		imageView = [[UIImageView alloc] initWithFrame:windowBounds];
	}
	[window addSubview:imageView];
	
	// Update the web view we present to the user to have
	// the same aspect ratio as the external screen.
	// TODO: This code doesn't work properly
	
	float scale = 1.0f;
	if (windowBounds.size.width > windowBounds.size.height) {
		scale = self.window.bounds.size.width / windowBounds.size.width;
	} else {
		scale = self.window.bounds.size.height / windowBounds.size.height;
	}
	
	CGRect frame = mainWebView.frame;
	frame.size.width = windowBounds.size.width * scale - 10;
	frame.size.height = windowBounds.size.height * scale - 10;
	mainWebView.frame = frame;
	
	// Finish it
	
	window.screen = screen;
	window.backgroundColor = [UIColor orangeColor];
	window.hidden = NO;
	
	self.secondWindow = window;
}

- (void)onTick {
	if (!mainWebView) return;
	
	// Grab the web view and render its contents
	// to an image.
	
	UIView *view = mainWebView;
	
	// Note: the last param (scale) can be set to a high value (ie 2.0) to make the image sharper
	// or a low one (ie 0.5) to make the image blurrier.
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
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
