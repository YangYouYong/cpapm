//
//  UINavigationController+Detector.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "UINavigationController+Detector.h"
#import <objc/runtime.h>
#import "NSObject+Detector.h"

@implementation UINavigationController (Detector)

+(void)prepareForDetector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(swizzled_pushViewController:animated:)];
    });
}

- (void)swizzled_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    [self swizzled_pushViewController:viewController animated:animated];
    
    [viewController markAlive];
    
}

@end
