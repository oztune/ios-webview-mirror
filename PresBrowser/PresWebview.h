//
//  OwnableWebview.h
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExternalWindow.h"

static  NSString * const kNotificationUserActivity = @"WDUserActivity";

@interface PresWebView : UIWebView <UIWebViewDelegate>

typedef enum {
    PresWebViewAspectScaled,
    PresWebViewAspectNative,
}PresWebViewAspectType;

@property (nonatomic) CGRect containerFrame;
@property (nonatomic) CGSize renderSize;
@property (nonatomic) PresWebViewAspectType currentAspect;
@property (strong, nonatomic) ExternalWindow *linkedWindow;

- (void) relayout;
- (void)rescaleWebViewContent;
- (UIImage*)screenshot;
- (void) assumeAspect: (PresWebViewAspectType) aspect;
- (void) linkWindow:(ExternalWindow*) window;
- (void) unlinkWindow;
@end
