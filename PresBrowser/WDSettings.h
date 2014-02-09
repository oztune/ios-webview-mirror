//
//  WDSettings.h
//  PresBrowser
//
//  Created by alex on 2/8/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDSettings : NSObject

+(WDSettings *) instance;

-(void) pushUrl: (NSString*) url;

@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic) NSArray *urlHistory;

@end
