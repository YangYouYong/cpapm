//
//  NSObject+Detector.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetectorProtocol.h"
#import "WTObjectProxy.h"

@interface NSObject (Detector)<DetectorProtocol>

+ (void)swizzleMethod:(SEL)originalMethod withMethod:(SEL)targetMethod;

@property (nonatomic, strong) WTObjectProxy *wtproxy;

@end
