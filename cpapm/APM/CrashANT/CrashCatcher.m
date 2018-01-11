//
//  CrashCatcher.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/3.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#include <sys/signal.h>
#import "CrashCatcher.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

//signal信号名
NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;   //表示最多只截获10次异常，如果超过十次则不截获弹出alter了直接崩溃

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 13;

@interface CrashCatcher()

@property (nonatomic, assign) NSTimeInterval execptionTime;

@end

@implementation CrashCatcher

+(instancetype)sharedInstance {
    static CrashCatcher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CrashCatcher alloc] init];
        sharedInstance.execptionTime = 30;
    });
    
    return sharedInstance;
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

-(void)setOpen:(BOOL)open {
    if (open) {
        NSSetUncaughtExceptionHandler(&catchCrash);
        setCrashSignalHandler();
    }
}

- (void)handleException:(NSException *)exception{
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    
    while (self.execptionTime > 0)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            //为阻止线程退出，使用 CFRunLoopRunInMode(model, 0.001, false)等待系统消息，false表示RunLoop没有超时时间
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
            self.execptionTime -= 0.001;
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    NSLog(@"%@",[exception name]);
    [self logLocalException:exception];
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

// you can report logs here or store them
-(void)logLocalException:(NSException *)exception {
    
    NSArray *stackArray = [CrashCatcher backtrace];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@\nUserInfo:%@\n",name, reason, stackArray,exception.userInfo];
    
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"debug_exception_log.txt"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:logFilePath]){
        [manager createFileAtPath:logFilePath contents:[exceptionInfo dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }else{
        NSData *data = [NSData dataWithContentsOfFile:logFilePath];
        NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        contents = [contents stringByAppendingString:exceptionInfo];
        [contents writeToFile:logFilePath atomically:true encoding:NSUTF8StringEncoding error:nil];
    }
}

// stack crash
void catchCrash(NSException *exception) {
    
    //递增一个全局计数器
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    //渠道回溯的堆栈
    NSArray *callStack = [CrashCatcher backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    
    //把堆栈信息存入字典中
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[CrashCatcher sharedInstance]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

// C or C++ API crash signal
void setCrashSignalHandler() {
    signal(SIGABRT, receiveSignal);
    signal(SIGILL, receiveSignal);
    signal(SIGSEGV, receiveSignal);
    signal(SIGFPE, receiveSignal);
    signal(SIGBUS, receiveSignal);
    signal(SIGPIPE, receiveSignal);
}

void receiveSignal(int signalType) {

    NSString *reason = [NSString stringWithFormat:@"Signal name:%@ \n was raised",[[CrashCatcher sharedInstance] nameOfSignal: signalType]];
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo = @{UncaughtExceptionHandlerSignalKey: @(signalType)}.mutableCopy;
    
    [userInfo
     setObject:[CrashCatcher backtrace]
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[CrashCatcher sharedInstance]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:reason
      userInfo:@{UncaughtExceptionHandlerSignalKey: @(signalType)}]
     waitUntilDone:YES];
    
    [[CrashCatcher sharedInstance] killApp];
}

-(NSString *)nameOfSignal:(int)signalType {
    switch (signalType) {
        case SIGABRT:
            return @"SIGABRT";
            break;
        case SIGILL:
            return @"SIGILL";
            break;
        case SIGSEGV:
            return @"SIGSEGV";
            break;
        case SIGFPE:
            return @"SIGFPE";
            break;
        case SIGBUS:
            return @"SIGBUS";
            break;
        case SIGPIPE:
            return @"SIGPIPE";
            break;
        default:
            return @"OTHER";
            break;
    }
}

-(void)killApp {
    
    NSSetUncaughtExceptionHandler(nil);
    
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    kill(getpid(), SIGKILL);
}

@end
