//
//  ExternalWindow.h
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalWindow : UIWindow{
}
@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) UIImageView* imageView;

- (void)checkForInitialScreen;
@end
