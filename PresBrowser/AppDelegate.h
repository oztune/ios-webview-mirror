//
//  AppDelegate.h
//  PresBrowser
//
//  Created by Oz Michaeli on 4/20/13.
//  Copyright (c) 2013 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresWebview.h"
#import "ExternalWindow.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIWebViewDelegate, UITextFieldDelegate>
{
    
	ExternalWindow *secondWindow;
    PresWebView *mainWebView;
	UIImageView *imageView;
    BOOL onExternal;
}
@property (strong, nonatomic) UIWindow *window;
@end
