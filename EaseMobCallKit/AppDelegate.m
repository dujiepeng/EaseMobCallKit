//
//  AppDelegate.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CallKit/CallKit.h>
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMOptions+PrivateDeploy.h>
#import "EMCallKitManager.h"
#import "UIViewController+Alert.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
    options.enableConsoleLog = YES;
#if DEBUG
    options.apnsCertName = @"EaseMobTestPush_dev";
#else
    options.apnsCertName = @"EaseMobTestPush";
#endif
    options.pushKitCertName = @"EaseMobTestVoip";
    
    
    options.enableDnsConfig = NO;
    options.usingHttpsOnly = NO;
    options.chatServer = @"116.85.43.118";
    options.chatPort = 6717;
    options.restServer = @"a1-hsb.easemob.com";
    options.isAutoLogin = YES;
    

    
    [EMClient.sharedClient initializeSDKWithOptions:options];
    
    [self enableAPNs];
    [EMCallKitManager.shared enableCallKit];
    
    return YES;
}

- (void)enableAPNs {
    UIApplication * application = [UIApplication sharedApplication];
    UNAuthorizationOptions apnsOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:apnsOptions
                                                                      completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window.rootViewController showTitle:@"推送为开启"
                                                  message:@"点击确定去设置"
                                               sureAction:^
                {
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication]openURL:url
                                                      options:@{}
                                            completionHandler:nil];
                }
                                                   cancel:^
                {
                    
                }];
            });
        }
    }];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 将收到的deviceToken传给环信
//    [EMClient.sharedClient registerForRemoteNotificationsWithDeviceToken:deviceToken completion:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self enableAPNs];
    [EMClient.sharedClient applicationWillEnterForeground:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [EMClient.sharedClient applicationDidEnterBackground:application];
}

@end
