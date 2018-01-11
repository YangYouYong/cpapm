//
//  ANTPingThread.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "ANTPingThread.h"

@interface ANTPingThread()

@property (nonatomic, copy) ANTPingThreadCallBack completion;
@property (nonatomic, assign) double threadHold;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) BOOL isMainThreadBlock;

@end

@implementation ANTPingThread

-(instancetype)init {
    if (self = [super init]) {
        self.semaphore = dispatch_semaphore_create(0);
        self.threadHold = 0.4;
    }
    return self;
}

-(void)startWithThreadHold:(double)threadHold completion:(ANTPingThreadCallBack)completionBlock {
    self.threadHold = threadHold;
    self.completion = completionBlock;
    [self start];
}

-(void)main {
    
    while (self.isCancelled == false) {
        self.isMainThreadBlock = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isMainThreadBlock = false;
            dispatch_semaphore_signal(self.semaphore);
        });
        
        [NSThread sleepForTimeInterval:self.threadHold];
        if (self.isMainThreadBlock) {
            if (self.completion) {
                self.completion();
            }
        }
        
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end
