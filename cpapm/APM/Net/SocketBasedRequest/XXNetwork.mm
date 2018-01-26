//
//  XXNetwork.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/26.
//  Copyright © 2018年 welltang. All rights reserved.
//

#include <iostream>
#include <fstream>
#include "HTTPRequest.hpp"
#import "XXNetwork.h"

@interface XXNetwork()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *requestTaskMap;

@end


@implementation XXNetwork

+ (XXNetwork *)sharedInstance
{
    static XXNetwork *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XXNetwork alloc] init];
        sharedInstance.queue = [[NSOperationQueue alloc] init];
        sharedInstance.requestTaskMap = @{}.mutableCopy;
    });

    return sharedInstance;
}


-(void)GET:(NSString *)url
     parms:(NSDictionary *)parms
completion:(CompletionBlock)completionBlock {
    
    NSDate *now = [NSDate date];
    NSString *requestTaskIdentifier = [url stringByAppendingString:[NSString stringWithFormat:@"_%.2f",[now timeIntervalSince1970]]];
    self.requestTaskMap[requestTaskIdentifier] = [completionBlock copy];
    
    NSBlockOperation *requestOperation = [NSBlockOperation blockOperationWithBlock:^{
       
        std::string requestUrl = [url UTF8String];
        std::string method = "GET";
        std::string arguments = ""; // parms format
        
        http::Request request(requestUrl);
        
        http::Response response = request.send(method, arguments, {
            "Content-Type: application/x-www-form-urlencoded",
            "User-Agent: runscope/0.1"
        });
        
        if (response.succeeded)
        {
            NSData *responseData = [NSData dataWithBytes:response.body.data() length:response.body.size()];
            CompletionBlock cpBlock = self.requestTaskMap[requestTaskIdentifier];
            if (cpBlock) {
                cpBlock(responseData, nil);
                self.requestTaskMap[requestTaskIdentifier] = nil;
            }
        }
        else
        {
            CompletionBlock cpBlock = self.requestTaskMap[requestTaskIdentifier];
            if (cpBlock) {
                NSError *error = [NSError errorWithDomain:@"Request failed"
                                                     code:0
                                                 userInfo:nil];
                cpBlock(nil, error);
                self.requestTaskMap[requestTaskIdentifier] = nil;
            }
        }
        
    }];
    
    [self.queue addOperation:requestOperation];
}

@end
