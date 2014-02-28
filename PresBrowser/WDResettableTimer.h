//
//  WDResettableTimer.h
//  PresBrowser
//
//  Created by alex on 2/3/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDResettableTimer : NSObject
{
    NSTimer *currentTimer;
}

@property (strong, readonly) id target;
@property(nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) BOOL repeats;
@property (nonatomic, readonly) NSTimeInterval interval;

+(WDResettableTimer*) resettableTimerWithTimeInterval:(NSTimeInterval) interval target:(id)target selector:(SEL)selector repeats:(BOOL) repeats;

-(void) start;
-(void) stop;
-(void) reset;
@end
