//
//  CFNetProxy.h
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/15.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFNetProxyModel.h"

@interface CFNetProxy : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSValue *, CFNetProxyModel *> *requestMap;
+(CFNetProxy *)sharedInstance;

@end
