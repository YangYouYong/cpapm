//
//  WTObjectProxy.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTObjectProxy : NSObject

-(void)prepareProxy:(NSObject *)target;

@property (nonatomic, weak) NSObject *weakTarget;
@property (nonatomic, weak) NSObject *weakResponder;// uiview responder

@end
