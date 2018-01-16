//
//  CFNetProxyModel.h
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/15.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 proxy model remember cf hook call back and request send argv
 */
@interface CFNetProxyModel : NSObject

@property (nonatomic, copy) NSString *requestId;    // mark request

@property (nonatomic, strong) NSValue *callbackPointer; // call back method pointer
@property (nonatomic, strong) NSValue *contextPointer;  // context pointer

@property (nonatomic, strong) NSMutableDictionary *readStreamProperty;
@property (nonatomic, strong) NSMutableDictionary *requestHeaderFields;
@property (nonatomic, strong) NSMutableDictionary *responseHeaderFields;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableData *bufferData;

+(NSString *)createReuestIdForRequest:(CFHTTPMessageRef)request;

@end
