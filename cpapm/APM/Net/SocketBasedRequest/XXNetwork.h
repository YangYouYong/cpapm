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

+ (XXNetwork *)sharedInstance;

-(void)GET:(NSString *)url
     parms:(NSDictionary *)parms
completion:(CompletionBlock)completionBlock;

@end
