//
//  EVGView.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/3.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "EVGView.h"

@implementation EVGView

//对象已经被释放，内存不合法，此块内存地址又没被覆盖，所以此内存内垃圾内存，所以调用方法的时候会导致SIGSEGV的错误
-(instancetype)init {
    self = [super init];
    if (self) {
        UIView *tempView = [[UIView alloc]init];
        [tempView release];
        
        [tempView setNeedsDisplay];
    }
    return self;
}

@end
