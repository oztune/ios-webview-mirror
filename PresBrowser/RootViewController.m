//
//  RootViewController.m
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "RootViewController.h"
#import <UIKit/UIKit.h>

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize urlField;
@synthesize rotateButton;
@synthesize swapButton;
@synthesize imageView;
@synthesize mainWebView;
@synthesize secondWindow;
@synthesize containingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        mainWebView = [[PresWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return self;
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
    secondWindow.imageView.image = image;
}

- (IBAction) swap{
    if(!secondWindow.isActive){
        return;
    }
    if(onExternal){
        [self setWebOnFirstScreen];
    }else{
        [self setWebOnSecondScreen];
    }
    return;
}

- (IBAction) rotate{
    [secondWindow rotate:[secondWindow successor:secondWindow.orientation] animate:YES];
    return;
}

- (void) handleDisplayChange{
    if(secondWindow.isActive){
        [mainWebView linkWindow: secondWindow];
    }else{
        [mainWebView unlinkWindow];
    }
}

- (void) setWebOnFirstScreen{
    [self.containingView addSubview:mainWebView];
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    imageView.hidden = YES;
    secondWindow.imageView.hidden = NO;
    onExternal = false;
}

- (void) setWebOnSecondScreen{
    imageView.frame = mainWebView.frame;
    [self onTick];

    [secondWindow addSubview:mainWebView];
    [mainWebView assumeAspect:PresWebViewAspectNative];

    secondWindow.imageView.hidden = YES;
    imageView.hidden = NO;
    onExternal = true;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [containingView addSubview:mainWebView];
    [containingView addSubview:imageView];
    mainWebView.frame = containingView.bounds;
    imageView.frame = containingView.bounds;
    
    onExternal = false;
    
    imageView.hidden = YES;
    imageView.alpha = 0.5;
    imageView.backgroundColor = [UIColor purpleColor];
    
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:@"externalUpdate" object:nil];
    
    CGRect externalFrame = CGRectMake(0, 0, 768, 1280);
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:externalFrame];
    [secondWindow checkForInitialScreen];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fireball.lga.appfigures.com/rrd/"]]];
    
	// Rendering timer
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
	
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    [mainWebView relayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [mainWebView relayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
