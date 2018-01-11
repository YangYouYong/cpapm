//
//  NetProtocol.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NetProtocol.h"

@interface NetProtocol()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *ant_request;
@property (nonatomic, strong) NSURLResponse *ant_response;
@property (nonatomic, strong) NSMutableData *ant_data;

@end

static NSMutableArray *delegates = nil;
static NSString *greenCard = @"greenCard";

@implementation NetProtocol

+(void)open {
    [NSURLProtocol registerClass:[self class]];
}

+(void)close {
    [NSURLProtocol unregisterClass:[self class]];
}

+(void)addDelegate:(id<NetAntDelegate>)delegate {
    if (!delegates) {
        delegates = @[].mutableCopy;
    }
    BOOL contains = [delegates containsObject:delegate];
    if (!contains) {
        [delegates addObject:delegate];
    }
}

+(void)removeDelegate:(id<NetAntDelegate>)delegate {
    [delegates removeObject:delegate];
}

+(NSArray *)delegates {
    return delegates;
}

#pragma mark -- override
+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:greenCard inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:greenCard
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

-(void)startLoading {
    
    NSURLRequest *request = [NetProtocol canonicalRequestForRequest:self.request];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
#pragma clang diagnostic pop
    
    self.ant_request = self.request;
}

-(void)stopLoading {
    [self.connection cancel];
    for (id<NetAntDelegate> delegate in delegates) {
        [delegate netAntDidCatchRequest:self.ant_request response:self.ant_response data:self.ant_data];
    }
}

#pragma mark - connection delegate & data

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

-(BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return true;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - data

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil) {
        self.ant_response = response;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return  request;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.ant_response = response;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    if (self.ant_data == nil) {
        self.ant_data = [data mutableCopy];
    }else{
        [self.ant_data appendData:data];
    }
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
