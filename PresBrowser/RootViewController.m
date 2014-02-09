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
        idleTimer = [WDResettableTimer resettableTimerWithTimeInterval:kIdleTimeout target:self selector:@selector(didGoIdle) repeats:true];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    NSString *text = textField.text;
    if(![text hasPrefix: @"http"]){
        text = [NSString stringWithFormat:@"http://%@", text];
    }
	[mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:text]]];
}

- (void) onTick{
    UIImage *image = [mainWebView screenshot];
    imageView.image = image;
    secondWindow.imageView.image = image;
}

- (IBAction) rotate{
    [secondWindow rotate:[secondWindow successor:secondWindow.orientation] animate:YES];
    return;
}

- (void) handleDisplayChange{
    if(secondWindow.isActive){
        [idleTimer start];
        [mainWebView linkWindow: secondWindow];
    }else{
        [idleTimer stop];
        [mainWebView unlinkWindow];
        if(onExternal){
            [self setWebOnFirstScreen];
        }
    }
}

- (void) setWebOnFirstScreen{
    [idleTimer start];
    if(!onExternal){
        NSLog(@"Attempted to swap to primary screen while already there");
        return;
    }
    [self.containingView addSubview:mainWebView];
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    imageView.hidden = YES;
    secondWindow.imageView.hidden = NO;
    onExternal = false;
}

- (void) setWebOnSecondScreen{

    [idleTimer stop];
    if(onExternal){
        NSLog(@"Attempted to swap to external while already on external");
        return;
    }
    
    if(!secondWindow.isActive){
        NSLog(@"Attempted to swap to external while it was inactive");
        return;
    }
    imageView.frame = mainWebView.frame;
    
    [self onTick];

    [secondWindow addSubview:mainWebView];
    [mainWebView assumeAspect:PresWebViewAspectNative];

    secondWindow.imageView.hidden = YES;
    imageView.hidden = NO;
    onExternal = true;
}

- (void) didGoIdle{
    NSLog(@"User went idle, trying to go to second screen");
    [self setWebOnSecondScreen];
}

- (void) didResumeFromIdle{
    NSLog(@"User went unidle");
    [self setWebOnFirstScreen];
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
    imageView.userInteractionEnabled = YES;
    
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:kNotificationExternalDisplayChange object:nil];
    
    // Idle timer
    [[NSNotificationCenter defaultCenter] addObserver:idleTimer selector:@selector(reset) name:kNotificationUserActivity object:nil];
    
    // Rendering timer
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    
    CGRect externalFrame = CGRectMake(0, 0, 768, 1280);
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:externalFrame];
    [secondWindow checkForInitialScreen];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fireball.lga.appfigures.com/rrd/"]]];
	
    
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!onExternal){
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    // catch touches on the imageview that's behind the webview so that
    // we know when to bring the webview back from the external screen
    UITouch *touch = [touches anyObject];
    UIView *touchedView = [touch view];
    if(touchedView == imageView){
        [self didResumeFromIdle];
    }
}

@end
