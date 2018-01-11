//
//  ANTPingThread.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ANTPingThreadCallBack)(void);

@interface ANTPingThread : NSThread

-(void)startWithThreadHold:(double)threadHold
                completion:(ANTPingThreadCallBack)completionBlock;

@end
