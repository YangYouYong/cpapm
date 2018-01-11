//
//  WTBacktrace.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "WTBacktrace.h"
#import "BSBacktraceLogger.h"
#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

@implementation WTBacktrace

+(NSString *)withThread:(NSThread *)thread {
    return [BSBacktraceLogger bs_backtraceOfNSThread:thread];
}

+(NSString *)currentThread {
    return [self withThread:[NSThread currentThread]];
}

+(NSString *)mainThread {
    return [self withThread:[NSThread mainThread]];
}

+(NSString *)allThread {
    
    thread_act_array_t threads = nil;
    mach_msg_type_number_t thread_count = 0;
    if (task_threads(mach_task_self_, &(threads), &thread_count) != KERN_SUCCESS) {
        return @"";
    }
    
    NSString *resultString = [NSString stringWithFormat:@"Call Backtrace of %d threads:\n", thread_count];
    
    for (int i = 0; i < thread_count; i++) {
        NSInteger index = i;
        NSString *bt = _bs_backtraceOfThread(threads[index]);
        resultString = [resultString stringByAppendingString:bt];
    }
    return resultString;
}

@end
