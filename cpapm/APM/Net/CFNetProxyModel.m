//
//  CFNetProxyModel.m
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/15.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import "CFNetProxyModel.h"

@implementation CFNetProxyModel

+(NSString *)createReuestIdForRequest:(CFHTTPMessageRef)request {
    NSURL *url = (__bridge NSURL *)CFHTTPMessageCopyRequestURL(request);
    NSString *method = (__bridge NSString *)CFHTTPMessageCopyRequestMethod(request);
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@_%@_%.2f",url.absoluteString, method, nowTime];
}

@end
