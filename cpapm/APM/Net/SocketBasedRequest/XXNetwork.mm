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
#import "CHttpRequest.h"

void responseCallBack(const char *requestIdentifier, char *resData, int status){
    // completion
    NSString *identifier = [NSString stringWithUTF8String:requestIdentifier];
    RequestTask *task = [XXNetwork sharedInstance].requestTaskMap[identifier];
    if (status != 1) {
        NSData *data = [NSData dataWithBytes:resData length:strlen(resData)];
        [task appendData:data];
    }else{
        CompletionBlock completion = task.completionBlock;
        if (completion) {
            completion(task.responseData, nil);
        }
    }
    
}

@interface XXNetwork()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong, readwrite) NSMutableDictionary *requestTaskMap;

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
    RequestTask *requestTask = [RequestTask new];
    requestTask.requestIdentifier = requestTaskIdentifier;
    requestTask.completionBlock = [completionBlock copy];
    self.requestTaskMap[requestTaskIdentifier] = requestTask;
    
    NSBlockOperation *requestOperation = [NSBlockOperation blockOperationWithBlock:^{
       
        /*
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
         */
        
        NSString *sliceString = @"://";
        NSRange range = [url rangeOfString:sliceString];
        NSString *clippedString = [url substringFromIndex:(range.location + range.length)];
        NSRange domainEndRange = [clippedString rangeOfString:@"/"];
        NSString *domain = [clippedString substringToIndex:domainEndRange.location];
        NSString *path = [clippedString substringFromIndex:domainEndRange.location];
//        if (![[path substringFromIndex:(path.length - 2)] isEqualToString:@"/"]) {
//            path = [path stringByAppendingString:@"/"];
//        }
        
        
        // link requestId and call back data
        
        getRequest([requestTaskIdentifier UTF8String],"HTTP/1.1", [domain UTF8String], [path UTF8String], responseCallBack);
        
    }];
    
    [self.queue addOperation:requestOperation];
}

@end

@interface RequestTask()

@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong) NSMutableData *processData;

@end

@implementation RequestTask

-(NSData *)responseData {
    return [NSData dataWithData:self.processData];
}

-(void)appendData:(NSData *)data {
    if (self.processData) {
        [self.processData appendData:data];
    }else{
        self.processData = [data mutableCopy];
    }
}

@end
