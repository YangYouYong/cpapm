//
//  method_check.h
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#ifndef method_check_h
#define method_check_h

#include <stdio.h>
#include <dlfcn.h>
#include <objc/objc.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// find out which method was hooked
static inline BOOL validate_methods(const char *cls,const char **swizzleName, const char **originalName, unsigned int *swizzledMethodCount) __attribute__ ((always_inline));

static inline const char *join(const char *, const char *) __attribute__ ((always_inline));
static inline const char *joinWithoutSpace(const char *, const char *) __attribute__ ((always_inline));

BOOL validate_methods(const char *cls,const char **swizzleName, const char **originalName, unsigned int *swizzledMethodCount){
    Class aClass = objc_getClass(cls);
    Method *methods;
    unsigned int nMethods;
    Dl_info info;
    IMP imp;
    char buf[128];
    Method m;
    const char *swizzledMethodNameList = NULL;
    const char *swizzledOriginalMethodNameList = NULL;
    unsigned int swizzledCount = 0;
    
    if(!aClass)
        return NO;
    methods = class_copyMethodList(aClass, &nMethods);
    while (nMethods--) {
        m = methods[nMethods];
        printf("validating [%s %s]\n",(const char *)class_getName(aClass), sel_getName(method_getName(m)));
        const char *function_name = sel_getName(method_getName(m));
        imp = method_getImplementation(m);
        //imp = class_getMethodImplementation(aClass, sel_registerName("allObjects"));
        if(!imp){
            printf("error:method_getImplementation(%s) failed\n",sel_getName(method_getName(m)));
            free(methods);
            return NO;
        }
        
        if(!dladdr(imp, &info)){
            printf("error:dladdr() failed for %s\n",sel_getName(method_getName(m)));
            free(methods);
            return NO;
        }
        
        
        const char *func_type = "-[";
        char type[] = "-";
        if (info.dli_sname) {
            strncpy(type, info.dli_sname, 1);
            if (strcmp(type, "+") == 0) {
                func_type = "+[";
            }else if (strcmp(type, "-") == 0){
                func_type = "-[";
            }else{
                printf("method:%s not class func also not instance",function_name);
            }
        }
        
        /*formate method*/
        const char *dli_function_name = joinWithoutSpace("-[", class_getName(aClass));
        dli_function_name = joinWithoutSpace(dli_function_name, " ");
        dli_function_name = joinWithoutSpace(dli_function_name, function_name);
        dli_function_name = joinWithoutSpace(dli_function_name, "]");
        
        if(strcmp(info.dli_sname, dli_function_name)){
            swizzledCount = swizzledCount + 1;
            swizzledOriginalMethodNameList = join(swizzledOriginalMethodNameList, function_name);
            swizzledMethodNameList = join(swizzledMethodNameList, info.dli_sname);
            continue;
        }
            if (info.dli_sname != NULL && strcmp(info.dli_sname, "<redacted>") != 0) {
            /*Validate class name in symbol*/
            snprintf(buf, sizeof(buf), "[%s ",(const char *) class_getName(aClass));
            if(strncmp(info.dli_sname + 1, buf, strlen(buf))){
                snprintf(buf, sizeof(buf),"[%s(",(const char *)class_getName(aClass));
                if(strncmp(info.dli_sname + 1, buf, strlen(buf))){
                    swizzledCount = swizzledCount + 1;
                    swizzledOriginalMethodNameList = join(swizzledOriginalMethodNameList, function_name);
                    swizzledMethodNameList = join(swizzledMethodNameList, info.dli_sname);
                    continue;
                }
            }
            
            /*Validate selector in symbol*/
            snprintf(buf, sizeof(buf), " %s]",(const char*)sel_getName(method_getName(m)));
            if(strncmp(info.dli_sname + (strlen(info.dli_sname) - strlen(buf)), buf, strlen(buf))){
                    swizzledCount = swizzledCount + 1;
                    swizzledOriginalMethodNameList = join(swizzledOriginalMethodNameList, function_name);
                    swizzledMethodNameList = join(swizzledMethodNameList, info.dli_sname);
                    continue;
            }
        }else{
            printf("<redacted>  \n");
        }
    }
    
    free(methods);
    *swizzledMethodCount = swizzledCount;
    *swizzleName = swizzledMethodNameList;
    *originalName = swizzledOriginalMethodNameList;
    return YES;
}

const char* join(const char *s1, const char *s2)
{
    if (s1 == NULL) {
        char *result = malloc(strlen(s2)+1);
        strcpy(result, s2);
        return result;
    }
    const char *separator = "\n";
    char *result = malloc(strlen(s1)+ strlen(separator) +strlen(s2)+1);
    if (result == NULL) exit (1);
    
    strcpy(result, s1);
    strcat(result, separator);
    strcat(result, s2);
    
    return result;
}

const char* joinWithoutSpace(const char *s1, const char *s2)
{
    if (s1 == NULL) {
        char *result = malloc(strlen(s2)+1);
        strcpy(result, s2);
        return result;
    }
    char *result = malloc(strlen(s1)+strlen(s2)+1);
    if (result == NULL) exit (1);
    
    strcpy(result, s1);
    strcat(result, s2);
    
    return result;
}

#endif /* method_check_h */
