//
//  AppDelegate.h
//  PresBrowser
//
//  Created by Oz Michaeli on 4/20/13.
//  Copyright (c) 2013 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIWebViewDelegate, UITextFieldDelegate>
{
	UIWindow *secondWindow;
	UIWebView *mainWebView;
	UIImageView *imageView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *secondWindow;

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification;
- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification;
- (void) onScreen: (UIScreen *)screen;

@end
