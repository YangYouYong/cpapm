//
//  NetAntURLSessionConfiguration.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetAntURLSessionConfiguration : NSObject

@property (nonatomic,assign) BOOL isSwizzle;
+ (NetAntURLSessionConfiguration *)defaultConfiguration;

+(void)open;
+(void)close;

@end
