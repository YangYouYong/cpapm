//
//  NetAnt.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetAntDelegate<NSObject>

-(void)netAntDidCatchRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data;

@end

@interface NetAnt : NSObject

@property (nonatomic, assign) id<NetAntDelegate> delegate;

+(BOOL)isWatching;

+(void)addObserver:(id<NetAntDelegate>)delegate;

+(void)removeObserver:(id<NetAntDelegate>)delegate;

@end
