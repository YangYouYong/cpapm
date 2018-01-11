//
//  UIView+Detector.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "UIView+Detector.h"
#import <objc/runtime.h>
#import "NSObject+Detector.h"

@implementation UIView (Detector)

+(void)prepareForDetector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(didMoveToSuperview) withMethod:@selector(swizzled_didMoveToSuperview)];
    });
}

- (void)swizzled_didMoveToSuperview
{
    [self swizzled_didMoveToSuperview];
    
    BOOL hasAliveParent = false;
    
    UIResponder* r = self.nextResponder;
    while (r) {
        if ([r wtproxy] != nil) {
            hasAliveParent = true;
            break;
        }
        r = r.nextResponder;
    }
    
    if (hasAliveParent) {
        [self markAlive];
    }
}

- (BOOL)isAlive
{
    BOOL alive = true;
    
    BOOL onUIStack = false;
    
    UIView* v = self;
    while (v.superview != nil) {
        v = v.superview;
    }
    if ([v isKindOfClass:[UIWindow class]]) {
        onUIStack = true;
    }
    
    //save responder
    if (self.wtproxy.weakResponder == nil) {
        UIResponder* r = self.nextResponder;
        while (r) {
            
            if (r.nextResponder == nil) {
                break;
            }else{
                r = r.nextResponder;
            }
            
            if ([r isKindOfClass:[UIViewController class]]) {
                break;
            }
        }
        self.wtproxy.weakResponder = r;
    }
    
    if (onUIStack == false) {
        alive = false;
        
        //if controller is active, view should be considered alive too
        if ([self.wtproxy.weakResponder isKindOfClass:[UIViewController class]]) {
            alive = true;
        }
    }
    
    return alive;
}


@end
