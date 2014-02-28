//
//  WDResettableTimer.m
//  PresBrowser
//
//  Created by alex on 2/3/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "WDResettableTimer.h"

@implementation WDResettableTimer

+(WDResettableTimer *)resettableTimerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeats:(BOOL)repeats{
    WDResettableTimer *timer = [[WDResettableTimer alloc] init];
    timer->_target = target;
    timer->_selector = selector;
    timer->_repeats = repeats;
    timer->_interval = interval;
    return timer;
}

-(void)start{
    if(currentTimer != nil){
        return; //already started
    }
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval target: self.target selector: self.selector userInfo:nil repeats: self.repeats];
}

-(void)stop{
    if(currentTimer == nil ){
        return; //already stopped
    }
    [currentTimer invalidate];
    currentTimer = nil;
    
}

-(void)reset{
    if(currentTimer == nil){
        return; //resetting a stopped timer has no effect
    }
    [self stop];
    [self start];
}
@end
