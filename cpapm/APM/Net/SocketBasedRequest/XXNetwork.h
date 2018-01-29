//
//  XXNetwork.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/26.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(NSData *, NSError *);

@interface XXNetwork : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *requestTaskMap;

+ (XXNetwork *)sharedInstance;

-(void)GET:(NSString *)url
     parms:(NSDictionary *)parms
completion:(CompletionBlock)completionBlock;

@end

@interface RequestTask: NSObject

@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NSString *requestIdentifier;
@property (nonatomic, strong, readonly) NSData *responseData;

-(void)appendData:(NSData *)data;

@end
