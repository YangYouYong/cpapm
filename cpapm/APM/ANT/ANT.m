//
//  ANT.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "ANT.h"
#import "WTBacktrace.h"
#import "ANTPingThread.h"

@interface ANT()

@property (nonatomic, strong) ANTPingThread *pingThread;

@end

@implementation ANT

-(BOOL)isOpen {
    return !self.pingThread.isCancelled;
}

-(void)openWithThreadhold:(double)threadHold {

    self.pingThread = [ANTPingThread new];
    __weak typeof(self) weakSelf = self;
    [self.pingThread startWithThreadHold:threadHold completion:^{
        NSString *main = [WTBacktrace mainThread];
        NSString *all = [WTBacktrace allThread];
        if (!weakSelf) {
            return ;
        }
        [weakSelf.delegate ANT:weakSelf
             catchWithThreadHold:threadHold
             mainThreadBacktrace:main
              allThreadBacktrace:all];
    }];
}

-(void)close {
    [self.pingThread cancel];
}

-(void)dealloc {
    [self.pingThread cancel];
}

@end

