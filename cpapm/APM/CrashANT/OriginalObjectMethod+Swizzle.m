//
//  OriginalObjectMethod+Swizzle.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "OriginalObjectMethod+Swizzle.h"
#import <objc/runtime.h>

@implementation OriginalObjectMethod (Swizzle)

+(void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(Foo));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(swizzle_Foo));
    method_exchangeImplementations(originalMethod, swizzledMethod);

    originalMethod = class_getInstanceMethod(self, @selector(Small));
    swizzledMethod = class_getInstanceMethod(self, @selector(swizzle_Small));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

-(void)swizzle_Foo {

    NSLog(@"swizzle func swizzle_Foo");
    [self swizzle_Foo];
}

-(void)swizzle_Small {
    NSLog(@"swizzle func swizzle_Small");
    [self swizzle_Small];
}

-(void)write {
    NSLog(@"method override in category");
}

+(void)install {
    NSLog(@"override in category");
}

@end
