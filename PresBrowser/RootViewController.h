//
//  RootViewController.h
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExternalWindow.h"
#import "PresWebview.h"

@interface RootViewController : UIViewController
{
    BOOL onExternal;
}

- (IBAction) swap;
- (IBAction) rotate;

@property (strong, nonatomic) ExternalWindow IBOutlet *secondWindow;
@property (strong, nonatomic) PresWebView IBOutlet *mainWebView;
@property (strong, nonatomic) UIImageView IBOutlet *imageView;
@property (strong, nonatomic) UIButton IBOutlet *rotateButton;
@property (strong, nonatomic) UIButton  IBOutlet *swapButton;
@property (strong, nonatomic) UITextField IBOutlet *urlField;

@end
