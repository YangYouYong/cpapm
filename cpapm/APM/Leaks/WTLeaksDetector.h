//
//  WTLeaksDetector.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Notif_WTDetector_Ping @"Notif_WTDetector_Ping"
#define Notif_WTDetector_Pong @"Notif_WTDetector_Pong"

@interface WTLeaksDetector : NSObject

+ (instancetype)sharedInstance;

-(void)startDetector;

@end
