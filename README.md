## iOS监控

1. [卡顿监控](#Blocked)
1. [内存泄露监控](#Leaks)
1. [网络监控](#Network)
1. [crash监控](#Crash)
1. [方法调换监控](#HookCheck)

### <a id='Blocked'> 卡顿监控  </a>

> 通过分析栈调用情况自顶向下查找卡顿的方法调用

```
2018-01-11 14:29:12.493901+0800 cpapm[16525:25693273] ----mainTrace----
2018-01-11 14:29:12.494088+0800 cpapm[16525:25693273] Backtrace of Thread 771:
libsystem_platform.dylib        0x114e71f49 _platform_memmove$VARIANT$Haswell + 41
CoreFoundation                  0x110f2b3d0 _CFStringCheckAndGetCharacters + 240
CoreFoundation                  0x110f2b282 -[__NSCFString getCharacters:range:] + 34
Foundation                      0x11007fd38 _NSNewStringByAppendingStrings + 1071
Foundation                      0x1100a2b2f -[NSString stringByAppendingString:] + 185
cpapm                           0x10fd734b0 -[TraceViewController blockFoo] + 128
cpapm                           0x10fd733f1 -[TraceViewController ANTTask:] + 257
UIKit                           0x111488972 -[UIApplication sendAction:to:from:forEvent:] + 83
UIKit                           0x111607c3c -[UIControl sendAction:to:forEvent:] + 67
UIKit                           0x111607f59 -[UIControl _sendActionsForEvents:withEvent:] + 450
UIKit                           0x111606e86 -[UIControl touchesEnded:withEvent:] + 618
UIKit                           0x1114fe807 -[UIWindow _sendTouchesForEvent:] + 2807

```

### <a id='Leaks'> 内存泄露监控  </a>

> 查看内存泄露的日志, 定位到具体的类. 可加入FBRetainCycle 找到具体引用关系

```
2018-01-11 14:32:33.153020+0800 cpapm[16525:25692073] *** <LeaksViewController: 0x7fd28e808430> is still alive ***
2018-01-11 14:32:33.153255+0800 cpapm[16525:25692073] 

Detect Possible Controller Leak: LeaksViewController

```

### <a id='Network'> 网络监控  </a>

> 通过设置代理 拿到每次网络请求的入参及返回值 做一些事情(如网络本地缓存, 网络调试等, 网络性能监控等)

```
// catch any network based on NSURLProtocol
-(void)netAntDidCatchRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data {
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (obj == nil) {
        obj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSLog(@"catch_request:%@\nresponse:%@,\ndata:%@",request.URL.absoluteString, response.URL.absoluteString, obj);
}

```

### <a id='Crash'> crash监控  </a>

> 通过拦截NSExecption对象 和拦截single 对象捕获crash 做crash 上报等事情.

```
/ you can report logs here or store them
-(void)logLocalException:(NSException *)exception {
    
    NSArray *stackArray = [CrashCatcher backtrace];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@\nUserInfo:%@\n",name, reason, stackArray,exception.userInfo];
    
    NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"debug_exception_log.txt"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:logFilePath]){
        [manager createFileAtPath:logFilePath contents:[exceptionInfo dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }else{
        NSData *data = [NSData dataWithContentsOfFile:logFilePath];
        NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        contents = [contents stringByAppendingString:exceptionInfo];
        [contents writeToFile:logFilePath atomically:true encoding:NSUTF8StringEncoding error:nil];
    }
}

```

### <a id='HookCheck'> 方法调换监控  </a>

> 通过C方法查找到当前类哪些方法被hook掉或者被category重写了. 用于hook系统方法前的检测

```

2018-01-11 14:40:35.325799+0800 cpapm[16525:25692073] swizzledInfo:(
        {
        originalName = Small;
        swizzledMethodName = "-[OriginalObjectMethod(Swizzle) swizzle_Small]";
    },
        {
        originalName = Foo;
        swizzledMethodName = "-[OriginalObjectMethod(Swizzle) swizzle_Foo]";
    },
        {
        originalName = write;
        swizzledMethodName = "-[OriginalObjectMethod(Swizzle) write]";
    },
        {
        originalName = "swizzle_Small";
        swizzledMethodName = "-[OriginalObjectMethod Small]";
    },
        {
        originalName = "swizzle_Foo";
        swizzledMethodName = "-[OriginalObjectMethod Foo]";
    }
)

```


TODO: 
> fishhook 监控基于CFNetwork的网络请求

> CPU爆表 & 内存爆表监控

> <del> PLeakSniffer 再造 </del>

> FileManager

>   ...