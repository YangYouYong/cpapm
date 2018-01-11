//
//  NetAntURLSessionConfiguration.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "NetAntURLSessionConfiguration.h"
#import <objc/runtime.h>
#import "NetProtocol.h"

@implementation NetAntURLSessionConfiguration

+ (NetAntURLSessionConfiguration *)defaultConfiguration {
    
    static NetAntURLSessionConfiguration *staticConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticConfiguration=[[NetAntURLSessionConfiguration alloc] init];
    });
    return staticConfiguration;
}

+(void)open {
    NetAntURLSessionConfiguration *defaultInstance = [NetAntURLSessionConfiguration defaultConfiguration];
    if (![defaultInstance isSwizzle]) {
        [defaultInstance load];
    }
}

+(void)close {
    NetAntURLSessionConfiguration *defaultInstance = [NetAntURLSessionConfiguration defaultConfiguration];
    if ([defaultInstance isSwizzle]) {
        [defaultInstance unload];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSwizzle=NO;
    }
    return self;
}

- (void)load {
    
    self.isSwizzle=YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    
}

- (void)unload {
    
    self.isSwizzle=NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

//如果需要导入其他的自定义NSURLProtocol请在这里增加，当然在使用NSURLSessionConfiguration时增加也可以
- (NSArray *)protocolClasses {
    
    return @[[NetProtocol class]];
}

@end
