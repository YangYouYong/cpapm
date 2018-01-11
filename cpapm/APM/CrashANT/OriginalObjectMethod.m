//
//  OriginalObjectMethod.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "OriginalObjectMethod.h"
#import <objc/runtime.h>
#import "method_check.h"
#import "NSObject+MethodSwizzleList.h"

@implementation OriginalObjectMethod

+(void)install {
    NSLog(@"class func :install");
}

-(void)Foo {
    NSLog(@"original func Foo:");
}

-(void)Small {
    NSLog(@"this is small func");
}

-(void)write {
    NSLog(@"original method write");
}

-(void)checkSwizzledMethod {
    // check method list  find out has hooked method
    
    NSMutableArray *swizzleMethodListArray = @[].mutableCopy;
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([self class], &methodCount);
    
    if (methodList) {
        
        NSLog(@"methodCount:%d",methodCount);
        
        const char *originalName = NULL;
        const char *swizzledMethodList = NULL;
        unsigned int swizzledCount = 0;
        BOOL validate = validate_methods(NSStringFromClass([self class]).UTF8String, &swizzledMethodList, &originalName, &swizzledCount);
        
        if (swizzledCount > 0 || !validate) {
            if (swizzledMethodList == NULL || originalName == NULL) {
                NSLog(@"swizzleNameList:%s,originalNameList:%s",swizzledMethodList, originalName);
                return ;
            }
            NSString *swizzledNameList = [[NSString stringWithUTF8String:swizzledMethodList] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            NSString *originalNameList = [[NSString stringWithUTF8String:originalName] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            NSArray *swizzledList = [swizzledNameList componentsSeparatedByString:@"\n"];
            NSArray *originalList = [originalNameList componentsSeparatedByString:@"\n"];
            
            for (int i = 0; i < swizzledCount; i ++) {
                NSString *methodOriginalName = originalList[i];
                NSString *swizzledName = swizzledList[i];
                NSMutableDictionary *swizzleInfoDict = @{}.mutableCopy;
                swizzleInfoDict[@"originalName"] = methodOriginalName;
                swizzleInfoDict[@"swizzledMethodName"] = swizzledName;
                [swizzleMethodListArray addObject: swizzleInfoDict];
            }
        }
        self.swizzleMethodList = swizzleMethodListArray;
        free(methodList);
    }
    NSLog(@"swizzledInfo:%@",self.swizzleMethodList);
}

@end
