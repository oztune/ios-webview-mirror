//
//  OwnableWebview.m
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "PresWebView.h"

@implementation PresWebView
@synthesize renderSize;
@synthesize containerFrame;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) assumeAspect:(PresWebViewAspectType)aspect{
    if(self.currentAspect == aspect){
        return;
    }
    self.currentAspect = aspect;
    [self relayout];
}

- (void) linkWindow:(ExternalWindow*) window{
    if(self.linkedWindow != nil){
        [self unlinkWindow];
    }
    self.linkedWindow = window;
    self.renderSize = window.bounds.size;
    [self relayout];
}

- (void) unlinkWindow{
    self.linkedWindow = nil;
    self.renderSize = self.containerFrame.size;
    [self relayout];
}

- (void) relayout{
    if (self.superview == nil){
        return;
    }
    [self updateContainer];

    if(self.currentAspect == PresWebViewAspectScaled){
        CGRect frame = self.frame;
        CGSize augmentedFrameSize = [self calculateScaleOf:self.renderSize withMax:containerFrame.size];
        frame.size = augmentedFrameSize;
        frame.origin = [self center:augmentedFrameSize in:containerFrame];
        NSLog(@"render: %@ (%@ -> %@)", NSStringFromCGSize(renderSize), NSStringFromCGRect(self.frame), NSStringFromCGRect(frame));
        [self setFrame: frame];
    }else{
        [self setFrame:CGRectMake(0, 0, self.renderSize.width, self.renderSize.height)];
    }
    [self rescaleWebViewContent];
}

-(void) updateContainer{
    CGSize newSize = self.superview.frame.size;
    if(newSize.width != containerFrame.size.width || newSize.height != containerFrame.size.height){
        containerFrame.size = newSize;
        containerFrame.origin = CGPointZero;
    }
    if(CGSizeEqualToSize(CGSizeZero, renderSize)){
        renderSize = containerFrame.size;
    }
}

-(void) setup{
    self.containerFrame = self.frame;
    self.renderSize = containerFrame.size;
    self.delegate = self;
    self.linkedWindow = nil;
    self.scalesPageToFit = YES;
    self.autoresizesSubviews = YES;
}

- (void)didMoveToSuperview{
    [self relayout];
}

- (CGSize) calculateScaleOf: (CGSize)other withMax: (CGSize) maxSize{
    float ratio = other.width / other.height;
    
    float attemptedWidth = ratio * maxSize.height;
    float attemptedHeight = maxSize.width / ratio;
    
    if(attemptedWidth > maxSize.width){
        attemptedWidth = maxSize.width;
        attemptedHeight = attemptedWidth / ratio;
    }
    
    if(attemptedHeight > maxSize.height){
        attemptedHeight = maxSize.height;
        attemptedWidth = ratio * attemptedHeight;
    }
    
    return CGSizeMake(attemptedWidth, attemptedHeight);
}

- (CGPoint) center: (CGSize) newSize in: (CGRect) space{
    float x = (space.size.width - newSize.width) / 2 + space.origin.x;
    float y = (space.size.height - newSize.height) / 2 + space.origin.y;
    return CGPointMake(x,y);
}


- (void)rescaleWebViewContent{
    int width = renderSize.width;
    float scale = self.frame.size.width / renderSize.width;
    
    NSLog(@"Resizing: %d -> %d (%f)", (int)renderSize.width, (int)self.frame.size.width, scale);
    // mucking with the meta is worth a shot, thanks stackoverflow
    // make the viewport the size of the external display and then scale.
    // that way the site lays out as it would if natively rendered on the external
    NSString *script = [NSString stringWithFormat:@"document.querySelector('meta[name=viewport]')"
                                                    ".setAttribute('content', '"
                                                    "width=%d,"
                                                    "initial-scale=%.2f,"
                                                    "minimum-scale=%.2f,"
                                                    "');",
                                                    width, scale, scale];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (UIImage*)screenshot{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    
    //take the screenshot
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
    return img;
}

// delegate stuff

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"1 Did fail");
    
    if (error.code == NSURLErrorCancelled) return;
    
	[[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if ([request.URL.absoluteString rangeOfString:@"olark"].length > 0) return NO;
    //	NSLog(@"2 %@, %i", request.URL.absoluteString, [request.URL.absoluteString rangeOfString:@"olark"].length > 0);
    //	NSLog(@"2 Should load, %@, %i", request, navigationType);
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self rescaleWebViewContent];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //	NSLog(@"4 Did start load");
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
