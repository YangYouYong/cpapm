//
//  NetAnt.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NetAnt.h"
#import "NetProtocol.h"
#import "NetAntURLSessionConfiguration.h"

@implementation NetAnt

+(BOOL)isWatching {
    return [NetProtocol delegates].count > 0;
}

+(void)addObserver:(id<NetAntDelegate>)delegate {
    if ([NetProtocol delegates].count <= 0) {
        [NetProtocol open];
        [NetAntURLSessionConfiguration open];
    }
    [NetProtocol addDelegate:delegate];
}

+(void)removeObserver:(id<NetAntDelegate>)delegate {
    [NetProtocol removeDelegate:delegate];
    if ([NetProtocol delegates].count <= 0) {
        [NetProtocol close];
        [NetAntURLSessionConfiguration close];
    }
}

@end
