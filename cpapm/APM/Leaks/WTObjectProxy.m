//
//  WTObjectProxy.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "WTObjectProxy.h"
#import "WTLeaksDetector.h"
#import "NSObject+Detector.h"

#define kLeakCheckMaxFailCount      5

@interface WTObjectProxy()

@property (nonatomic, assign) BOOL markLeaks;
@property (nonatomic, assign) NSInteger checkLeaksCount;

@end

@implementation WTObjectProxy

-(void)prepareProxy:(NSObject *)target {
    
    self.weakTarget = target;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notif_WTDetector_Ping object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPing) name:Notif_WTDetector_Ping object:nil];
}

-(void)detectPing {
    if (!self.weakTarget) {
        return;
    }
    if (_markLeaks) {
        return;
    }
    
    BOOL alive = [self.weakTarget isAlive];
    if (alive == false) {
        _checkLeaksCount += 1;
    }
    
    if (self.checkLeaksCount >= kLeakCheckMaxFailCount) {
        _markLeaks = true;
        NSLog(@"*** %@ is still alive *** \n",self.weakTarget);
        [[NSNotificationCenter defaultCenter] postNotificationName:Notif_WTDetector_Pong object:self.weakTarget];
    }
}

@end
