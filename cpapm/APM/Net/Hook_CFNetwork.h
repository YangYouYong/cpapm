//
//  Hook_CFNetwork.h
//  WellTangAPM
//
//  Created by yangyouyong on 2018/1/12.
//  Copyright © 2018年 welltang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CFNetProxy.h"
#import "CFNet.h"

#define CFRequest_KEY @"hook_requestId"

// TODO: proxystream receive data and send data to target stream;
static void hooked_proxyCallBack(CFReadStreamRef stream,CFStreamEventType type,void *clientCallBackInfo);
void hooked_proxyCallBack(CFReadStreamRef stream,CFStreamEventType type,void *clientCallBackInfo){

    NSDictionary *proxyInfo = CFBridgingRelease(CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPProxy));
    NSString *requestId = proxyInfo[CFRequest_KEY];
    NSMutableDictionary *proxyCallBackMap = [CFNetProxy sharedInstance].requestMap;

    CFReadStreamClientCallBack original_callback = NULL;
    if (clientCallBackInfo != NULL) {
        CFNetProxyModel *proxy = proxyCallBackMap[requestId];
        if (proxy) {
            original_callback = [proxy.callbackPointer pointerValue];
        }else{
            NSLog(@"missed_data");
        }
    }
    
    CFReadStreamRef readStream = stream;
    
    if(type == kCFStreamEventHasBytesAvailable){
        
        CFNetProxyModel *proxy = proxyCallBackMap[requestId];
        if (proxy) {
            // proxy receive data
            /**
                UInt8 buff[255];
                long length = CFReadStreamRead(stream, buff, 255);
                NSMutableData *mutiData = proxy.bufferData;
                if(!mutiData){
                    mutiData = [[NSMutableData alloc] init];
                }
                [mutiData appendBytes:buff length:length];
             
                proxy.bufferData = mutiData;
             */
        }
        
    }else if(type == kCFStreamEventEndEncountered){

        // end data
        CFNetProxyModel *proxy = proxyCallBackMap[requestId];
        if (proxy) {
            proxy.responseData = proxy.bufferData;
        }
        NSLog(@"proxy complete");
    }
    
    if (original_callback != NULL) {
        original_callback(readStream, type, clientCallBackInfo);
    }
}

static Boolean (*original_CFReadStreamSetClient)(CFReadStreamRef, CFOptionFlags, CFReadStreamClientCallBack, CFStreamClientContext *);

static Boolean wt_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);

Boolean wt_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext) {
    
    NSDictionary *proxyInfo = CFBridgingRelease(CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPProxy));
    NSString *requestId = proxyInfo[CFRequest_KEY];
    
    NSMutableDictionary *proxyCallBackMap = [CFNetProxy sharedInstance].requestMap;
    if (clientContext != NULL && clientContext->info != NULL) {
        NSValue *objectKey = [NSValue valueWithPointer:clientContext->info];
        CFNetProxyModel *proxy = proxyCallBackMap[requestId];
        if (proxy && proxy.callbackPointer == nil) {
            
            proxy.callbackPointer = [NSValue valueWithPointer:clientCB];
            return original_CFReadStreamSetClient(stream, streamEvents, hooked_proxyCallBack, clientContext);
        }
    }

    return original_CFReadStreamSetClient(stream, streamEvents, clientCB, clientContext);
}

static CFReadStreamRef (*original_CFReadStreamCreateForHTTPRequest)(CFAllocatorRef, CFHTTPMessageRef);

static CFReadStreamRef
wt_CFReadStreamCreateForHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request);
CFReadStreamRef wt_CFReadStreamCreateForHTTPRequest(CFAllocatorRef __nullable alloc, CFHTTPMessageRef request) {
    
    NSURL *url = (__bridge NSURL *)CFHTTPMessageCopyRequestURL(request);
    NSString *method = (__bridge NSString *)CFHTTPMessageCopyRequestMethod(request);
    NSString *requestId = [CFNetProxyModel createReuestIdForRequest:request];
    CFReadStreamRef readStream = original_CFReadStreamCreateForHTTPRequest(alloc, request);
    
    CFReadStreamSetProperty(readStream, CFSTR("StreamID"), (__bridge CFTypeRef)requestId);
    
    // mark request
    NSDictionary *proxyInfo = CFBridgingRelease(CFReadStreamCopyProperty(readStream, kCFStreamPropertyHTTPProxy));
    NSMutableDictionary *userInfo = [proxyInfo mutableCopy];
    if (userInfo == nil) {
        userInfo = @{}.mutableCopy;
    }
    userInfo[CFRequest_KEY] = requestId;
    CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPProxy, (__bridge CFTypeRef)(userInfo));
    
    NSMutableDictionary *proxyCallBackMap = [CFNetProxy sharedInstance].requestMap;
    if (requestId.length > 0) {
        if (!proxyCallBackMap[requestId]) {
            CFNetProxyModel *model = [CFNetProxyModel new];
            model.requestId = requestId;
            proxyCallBackMap[requestId] = model;
        }
    }
    return readStream;
}

// TODO: mark request status
static Boolean (*original_CFReadStreamOpen)(CFReadStreamRef);
static Boolean wt_CFReadStreamOpen(CFReadStreamRef stream);
Boolean wt_CFReadStreamOpen(CFReadStreamRef stream) {
    
    return original_CFReadStreamOpen(stream);
}

// TODO: mark request status
static Boolean (*original_CFReadStreamClose)(CFReadStreamRef);
static Boolean wt_CFReadStreamClose(CFReadStreamRef stream);
Boolean wt_CFReadStreamClose(CFReadStreamRef stream) {
    NSDictionary *proxyInfo = CFBridgingRelease(CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPProxy));
    return original_CFReadStreamClose(stream);
}

static CFTypeRef (*original_CFReadStreamSetProperty)(CFReadStreamRef, CFStreamPropertyKey, CFTypeRef);
static Boolean wt_CFReadStreamSetProperty(CFReadStreamRef stream, CFStreamPropertyKey propertyName, CFTypeRef propertyValue);
Boolean wt_CFReadStreamSetProperty(CFReadStreamRef stream, CFStreamPropertyKey propertyName, CFTypeRef propertyValue) {
    
    if (propertyName == kCFStreamPropertyHTTPProxy) {
        NSDictionary *proxyInfo = CFBridgingRelease(CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPProxy));
        NSMutableDictionary *userInfo = [proxyInfo mutableCopy];
        if (userInfo == nil) {
            return original_CFReadStreamSetProperty(stream,propertyName, propertyValue);
        }
        id va = (__bridge id)propertyValue;
        if ([va isKindOfClass:[NSDictionary class]]) {
            NSDictionary *infoDict = va;
            for (NSString *key in [infoDict allKeys]) {
                id value = infoDict[key];
                userInfo[key] = value;
            }
        }
        return original_CFReadStreamSetProperty(stream,propertyName, (__bridge CFTypeRef)userInfo);
    }
    
    return original_CFReadStreamSetProperty(stream,propertyName, propertyValue);
}
