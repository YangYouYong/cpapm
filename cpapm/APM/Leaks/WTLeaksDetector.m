//
//  WTLeaksDetector.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "WTLeaksDetector.h"
#import <UIKit/UIKit.h>
#import "NSObject+Detector.h"

@interface WTLeaksDetector()

@property (nonatomic, strong) NSTimer* pingTimer;

@end

@implementation WTLeaksDetector

+ (instancetype)sharedInstance {
    static WTLeaksDetector* instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [WTLeaksDetector new];
    });
    
    return instance;
}

-(void)startDetector {
    
    [UINavigationController prepareForDetector];
    [UIViewController prepareForDetector];
    
    [self startPingTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notif_WTDetector_Pong object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPong:) name:Notif_WTDetector_Pong object:nil];
}

- (void)startPingTimer
{
    if ([NSThread isMainThread] == false) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startPingTimer];
            return ;
        });
    }
    
    if (self.pingTimer) {
        return;
    }
    
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(sendPing)
                                                    userInfo:nil
                                                     repeats:true];
    
    [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
}

- (void)sendPing {
    [[NSNotificationCenter defaultCenter] postNotificationName:Notif_WTDetector_Ping object:nil];
}

- (void)detectPong:(NSNotification*)notif {
    NSObject* leakedObject = notif.object;
    
    if ([leakedObject isKindOfClass:[UIViewController class]]) {
        NSLog(@"\n\nDetect Possible Controller Leak: %@ \n\n", [leakedObject class]);
    }else{
        NSLog(@"\n\nDetect Possible Leak: %@ \n\n", [leakedObject class]);
    }
}

@end
