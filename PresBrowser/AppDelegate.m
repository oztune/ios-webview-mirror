//
//  AppDelegate.m
//  PresBrowser
//
//  Created by Oz Michaeli on 4/20/13.
//  Copyright (c) 2013 Oz Michaeli. All rights reserved.
//

#import "AppDelegate.h"
#import "PresWebview.h"

@implementation AppDelegate

@synthesize window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
	
	// Set up the UI
    onExternal = false;
	UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(10,30, 300, 30)];
	input.backgroundColor = [UIColor whiteColor];
	input.autocapitalizationType = UITextAutocapitalizationTypeNone;
	input.keyboardType = UIKeyboardTypeURL;
	input.delegate = self;
	[self.window addSubview:input];
    
    UIButton *rescale = [UIButton buttonWithType:UIButtonTypeSystem];
    rescale.frame = CGRectMake(350, 30, 100, 30);
    [rescale addTarget:mainWebView action:@selector(rescaleWebViewContent) forControlEvents:UIControlEventTouchUpInside];
    rescale.backgroundColor = [UIColor whiteColor];
    rescale.titleLabel.textColor = [UIColor blackColor];
    [rescale setTitle:@"Refresh" forState:UIControlStateNormal];
    [self.window addSubview:rescale];
    
    UIButton *swap = [UIButton buttonWithType:UIButtonTypeSystem];
    swap.frame = CGRectMake(500, 30, 100, 30);
    [swap addTarget:self action:@selector(swap) forControlEvents:UIControlEventTouchUpInside];
    swap.backgroundColor = [UIColor whiteColor];
    swap.titleLabel.textColor = [UIColor blackColor];
    [swap setTitle:@"Swap" forState:UIControlStateNormal];
    [self.window addSubview:swap];
    
    //frame that we'll be using for the
    CGSize size = self.window.frame.size;
    CGRect frame = CGRectMake(0, 70, size.width, size.height-70);
    
    imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.hidden = YES;
    imageView.alpha = 0.5;
    imageView.backgroundColor = [UIColor purpleColor];
    [self.window addSubview:imageView];
    
	mainWebView = [[PresWebView alloc] initWithFrame:frame];
    [mainWebView assumeAspect:PresWebViewAspectScaled];
	[self.window addSubview:mainWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:@"externalUpdate" object:nil];
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:frame];
    [secondWindow checkForInitialScreen];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fireball.lga.appfigures.com/rrd/"]]];
		
	// Rendering timer
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
	
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    NSString *text = textField.text;
    if(![text hasPrefix: @"http"]){
        text = [NSString stringWithFormat:@"http://%@", text];
    }
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:text]]];
	
    return NO;
}

- (void) onTick{
    if(!secondWindow.isActive){
        if(onExternal){
            [self setWebOnFirstScreen];
        }
        return;
    }
    UIImage *image = [mainWebView screenshot];
    imageView.image = image;
    secondWindow.imageView.image = [mainWebView screenshot];
}

- (BOOL) swap{
    if(!secondWindow.isActive){
        return false;
    }
    if(onExternal){
        [self setWebOnFirstScreen];
    }else{
        [self setWebOnSecondScreen];
    }
    return true;
}

- (void) handleDisplayChange{
    if(secondWindow.isActive){
        [mainWebView linkWindow: secondWindow];
    }else{
        [mainWebView unlinkWindow];
    }
}

- (void) setWebOnFirstScreen{
    [mainWebView removeFromSuperview];
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    imageView.hidden = YES;
    secondWindow.imageView.hidden = NO;
    [window addSubview:mainWebView];
    onExternal = false;
}

- (void) setWebOnSecondScreen{
    [mainWebView removeFromSuperview];
    imageView.frame = mainWebView.frame;
    [mainWebView assumeAspect:PresWebViewAspectNative];
    imageView.hidden = NO;
    secondWindow.imageView.hidden = YES;
    [secondWindow addSubview:mainWebView];
    onExternal = true;
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

@end
