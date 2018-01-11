//
//  WTBacktrace.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pthread.h>

@interface WTBacktrace : NSObject

+(NSString *)withThread:(NSThread *)thread;
+(NSString *)currentThread;
+(NSString *)mainThread;
+(NSString *)allThread;

@end
