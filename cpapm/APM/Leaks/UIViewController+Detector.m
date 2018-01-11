//
//  UIViewController+Detector.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "UIViewController+Detector.h"
#import "NSObject+Detector.h"
#import <objc/runtime.h>

@implementation UIViewController (Detector)

+(void)prepareForDetector {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(presentViewController:animated:completion:) withMethod:@selector(swizzled_presentViewController:animated:completion:)];
    });
}

- (void)swizzled_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion {
    [self swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
    
    [viewControllerToPresent markAlive];
}

- (BOOL)isAlive
{
    BOOL alive = true;
    
    BOOL visibleOnScreen = false;
    
    UIView* v = self.view;
    while (v.superview != nil) {
        v = v.superview;
    }
    if ([v isKindOfClass:[UIWindow class]]) {
        visibleOnScreen = true;
    }
    
    
    BOOL beingHeld = false;
    if (self.navigationController != nil || self.presentingViewController != nil) {
        beingHeld = true;
    }
    
    //not visible, not in view stack
    if (visibleOnScreen == false && beingHeld == false) {
        alive = false;
    }
    
    return alive;
}

@end
