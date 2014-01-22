//
//  RootViewController.m
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize urlField;
@synthesize refreshButton;
@synthesize swapButton;
@synthesize imageView;
@synthesize mainWebView;
@synthesize secondWindow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // no-op
    }
    return self;
}

- (void)setup{
    onExternal = false;
    
    imageView.hidden = YES;
    imageView.alpha = 0.5;
    imageView.backgroundColor = [UIColor purpleColor];

    [mainWebView assumeAspect:PresWebViewAspectScaled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:@"externalUpdate" object:nil];
    
    CGRect externalFrame = CGRectMake(0, 0, 1280, 768);
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:externalFrame];
    [secondWindow checkForInitialScreen];
    [mainWebView linkWindow: secondWindow];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fireball.lga.appfigures.com/rrd/"]]];
    
	// Rendering timer
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
	
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

- (IBAction) refresh{
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
    [mainWebView removeFromSuperview];
    [mainWebView assumeAspect:PresWebViewAspectScaled];
    imageView.hidden = YES;
    secondWindow.imageView.hidden = NO;
    [self.view addSubview:mainWebView];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
