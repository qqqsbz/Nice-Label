//
//  AppDelegate.m
//  Radar
//
//  Created by coder on 15/9/7.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "AppDelegate.h"
#import "MapAroundPlaceApi.h"
#import <MAMapKit/MAMapServices.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1、apikey 申请请看这里http://lbs.amap.com/api/ios-sdk/guide/verify/
    [MAMapServices sharedServices].apiKey = @"4657b4e0e84c973a247349dbd354216e";
    [MapAroundPlaceApi shareMapAroundPlaceApi].searchKey = @"4657b4e0e84c973a247349dbd354216e";
    // 2、坐标转换key  申请请看这里 http://lbsbbs.amap.com/forum.php?mod=viewthread&tid=724&highlight=%E5%9D%90%E6%A0%87%E8%BD%AC%E6%8D%A2
    [MapAroundPlaceApi shareMapAroundPlaceApi].convertKey= @"1f1d50bae430769d26d82615f428c4f5";
    // 3、在Info添加 NSLocationWhenInUseUsageDescription、NSLocationAlwaysUsageDescription
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
