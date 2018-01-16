//
//  CFNet.h
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/12.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFNet : NSObject

@property (nonatomic, strong) NSMutableDictionary *responseMap;
@property (nonatomic, strong) NSMutableDictionary *responseDataMap;

// hook cfnetwork
+(void)install;

-(void)testCFGetClient;
-(void)testCFGetClient2;

-(void)testCFGetClientCompletion:(void(^)(NSData *))completionBlock;

-(void)testCFGetClientCompletion:(void(^)(NSData *))completionBlock;
-(void)testCFGetClient2Completion:(void(^)(NSData *))completionBlock;


@end
