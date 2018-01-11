//
//  DetectorProtocol.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetectorProtocol <NSObject>

+(void)prepareForDetector;

-(BOOL)markAlive;

-(BOOL)isAlive;

@end
