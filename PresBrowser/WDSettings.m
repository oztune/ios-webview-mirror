//
//  WDSettings.m
//  PresBrowser
//
//  Created by alex on 2/8/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "WDSettings.h"

@implementation WDSettings

static WDSettings *_instance = nil;
static NSString * const kOrientationKey = @"WDSettingOrientation";
static NSString * const kHistoryKey = @"WDSettingHistory";
static const int kMaxHistory = 50;
NSUserDefaults *defaults;

+(WDSettings *)instance{
    if(_instance == nil){
        _instance = [[WDSettings alloc]init];
    }
    return _instance;
}

-(WDSettings *)init{
    self = [super init];
    if(self){
        defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
        [defaultValues
            setObject: [NSString stringWithFormat: @"%d", (int)UIInterfaceOrientationLandscapeRight]
            forKey:kOrientationKey];
        [defaultValues setObject:[NSArray array] forKey:kHistoryKey];
        [defaults registerDefaults:defaultValues];
    }
    return self;
}

- (UIInterfaceOrientation)orientation{
    return (UIInterfaceOrientation)[defaults integerForKey:kOrientationKey];
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
    [defaults setInteger:(int)orientation forKey: kOrientationKey];
    [defaults synchronize];
}

-(void)pushUrl:(NSString *)url{
    NSMutableArray *copy = [NSMutableArray arrayWithArray:[self urlHistory]];
    [copy removeObject:url];
    if([copy count] +1 > kMaxHistory){
        [copy removeObjectAtIndex:0];
    }
    [copy addObject:url];
    [self setUrlHistory:copy];
}

-(NSArray *)urlHistory{
    return [defaults stringArrayForKey:kHistoryKey];
}

-(void)setUrlHistory:(NSArray *)urlHistory{
    [defaults setValue:urlHistory forKey:kHistoryKey];
    [defaults synchronize];
}


@end
