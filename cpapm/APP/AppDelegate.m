//
//  AppDelegate.m
//  cpapm
//
//  Created by yangyouyong on 2017/12/28.
//  Copyright © 2017年 cpbee. All rights reserved.
//

#import "AppDelegate.h"
#import "CrashCatcher.h"
#import "WTLeaksDetector.h"
#import "CFNet.h"

#import "XXNetwork.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [[PLeakSniffer sharedInstance] installLeakSniffer];
    [[CrashCatcher sharedInstance] setOpen:true];
    [[WTLeaksDetector sharedInstance] startDetector];
    [CFNet install];
    NSLog(@"home: %@",NSHomeDirectory());
    
    for (int i = 0; i < 1; i++) {
        NSLog(@"request: %d",i);
        [[XXNetwork sharedInstance] GET:@"http://httpbin.org/ip" parms:nil completion:^(NSData *responseData, NSError *error) {
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            if (json == nil) {
                NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"%@",str);
            }
            NSLog(@"response: %@",json);
        }];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
