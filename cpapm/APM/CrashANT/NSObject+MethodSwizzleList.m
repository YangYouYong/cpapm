//
//  NSObject+MethodSwizzleList.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/29.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NSObject+MethodSwizzleList.h"
#import <objc/runtime.h>

static const void *methodListKey = &methodListKey;

@implementation NSObject (MethodSwizzleList)

-(NSArray *)swizzleMethodList {
    return objc_getAssociatedObject(self, methodListKey);
}

-(void)setSwizzleMethodList:(NSArray *)swizzleMethodList {
    objc_setAssociatedObject(self, methodListKey, swizzleMethodList, OBJC_ASSOCIATION_RETAIN);
}

@end
