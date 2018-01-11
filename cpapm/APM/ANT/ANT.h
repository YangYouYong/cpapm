//
//  ANT.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANT;
@protocol ANTDelegate<NSObject>

-(void)ANT:(ANT *)ant
catchWithThreadHold:(double)threadHold
mainThreadBacktrace:(NSString *)mainBacktrace
allThreadBacktrace:(NSString *)allBacktrace;

@end

@interface ANT : NSObject

@property (nonatomic, assign) id<ANTDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isOpen;

-(void)openWithThreadhold:(double)threadHold;
-(void)close;

@end

