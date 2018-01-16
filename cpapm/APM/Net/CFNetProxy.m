//
//  CFNetProxy.m
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/15.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import "CFNetProxy.h"
#import "Hook_CFNetwork.h"

@implementation CFNetProxy

+ (CFNetProxy *)sharedInstance
{
    static CFNetProxy *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CFNetProxy alloc] init];
        instance.requestMap = @{}.mutableCopy;
    });
    return instance;
}
@end
