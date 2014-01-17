//
//  ExternalWindow.m
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "ExternalWindow.h"

@implementation ExternalWindow
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set up the AirPlay code
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                       name:UIScreenDidConnectNotification object:nil];
        [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                       name:UIScreenDidDisconnectNotification object:nil];
        
        // Create an image inside the window so that we can draw
        // the web view into it.
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:frame];
        }
        self.backgroundColor = [UIColor orangeColor];
        self.hidden = YES;
        [self addSubview:imageView];
    }
    return self;
}

- (void) onScreen: (UIScreen *)screen {
    // These are the bounds of the external screen
	CGRect screenBounds = screen.applicationFrame;
	
	screen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
	// ROTATE the window
	// This code is wonky and should be redone
    CGRect windowBounds = screenBounds;
    windowBounds.size = CGSizeMake(windowBounds.size.height, windowBounds.size.width);
    self.frame = windowBounds;
	self.center = CGPointMake(screenBounds.origin.x + screenBounds.size.width/2, screenBounds.origin.y + screenBounds.size.height/2);
	self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
	
    imageView.frame = windowBounds;
    
	// Finish it
	self.isActive = YES;
	self.screen = screen;
    self.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalUpdate" object:self];

}

- (void)checkForInitialScreen{
    if ([[UIScreen screens] count] > 1) {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        [self onScreen:secondScreen];
    }
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
	[self onScreen:newScreen];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    self.isActive = NO;
    self.screen = nil;
    self.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"externalUpdate" object:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
