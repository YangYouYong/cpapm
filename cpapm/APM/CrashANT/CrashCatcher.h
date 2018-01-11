//
//  CrashCatcher.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/3.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashCatcher : NSObject

+(instancetype)sharedInstance;

+(NSArray *)backtrace;  // return call stacks

-(void)setOpen:(BOOL)open;

-(NSString *)nameOfSignal:(int)signalType;

-(void)killApp;

void catchCrash(NSException *exception);

/////////////////// signal type and funcs //////////////////

void receiveSignal(int signalType);

////////////////////////////////////////////////////////////

@end
