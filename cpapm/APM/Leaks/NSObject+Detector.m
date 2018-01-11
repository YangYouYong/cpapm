//
//  NSObject+Detector.m
//  cpapm
//
//  Created by yangyouyong on 2018/1/11.
//  Copyright © 2018年 cpbee. All rights reserved.
//

#import "NSObject+Detector.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation NSObject (Detector)

+(void)swizzleMethod:(SEL)originalMethod withMethod:(SEL)targetMethod {
   
    // check has hooked then hook the hooked method
    
    Class class = [self class];
    
    Method originalM = class_getInstanceMethod(class, originalMethod);
    Method swizzledM = class_getInstanceMethod(class, targetMethod);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalMethod,
                    method_getImplementation(swizzledM),
                    method_getTypeEncoding(swizzledM));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            targetMethod,
                            method_getImplementation(originalM),
                            method_getTypeEncoding(originalM));
    }else{
        method_exchangeImplementations(originalM, swizzledM);
    }
    
}

@dynamic wtproxy;
-(void)setWtproxy:(WTObjectProxy *)wtproxy {
    objc_setAssociatedObject(self, sel_getName(@selector(wtproxy)), wtproxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(WTObjectProxy *)wtproxy {
    return objc_getAssociatedObject(self, sel_getName(@selector(wtproxy)));
}

+ (void)prepareForSniffer {
    
}

-(BOOL)isAlive {
    return true;
}

-(BOOL)markAlive {
    if (self.wtproxy != nil) {
        return false;
    }
    
    //skip system class
    NSString* className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"_"] || [className hasPrefix:@"UI"] || [className hasPrefix:@"NS"]) {
        return false;
    }
    
    //view object needs a super view to be alive
    if ([self isKindOfClass:[UIView class]]) {
        UIView* v = (UIView*)self;
        if (v.superview == nil) {
            return false;
        }
    }
    
    //controller object needs a parent to be alive
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController* c = (UIViewController*)self;
        if (c.navigationController == nil && c.presentingViewController == nil) {
            return false;
        }
    }
    
    //skip some weird system classes
    static NSMutableDictionary* ignoreList = nil;
    @synchronized (self) {
        if (ignoreList == nil) {
            ignoreList = @{}.mutableCopy;
            NSArray* arr = @[@"UITextFieldLabel", @"UIFieldEditor", @"UITextSelectionView",
                             @"UITableViewCellSelectedBackground", @"UIView", @"UIAlertController"];
            for (NSString* str in arr) {
                ignoreList[str] = @":)";
            }
        }
        if ([ignoreList objectForKey:NSStringFromClass([self class])]) {
            return false;
        }
    }
    
    WTObjectProxy *proxy = [WTObjectProxy new];
    self.wtproxy = proxy;
    [self.wtproxy prepareProxy:self];
    return true;
}

@end
