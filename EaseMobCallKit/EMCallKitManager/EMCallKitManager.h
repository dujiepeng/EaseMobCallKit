//
//  EMCallKitManager.h
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface EMCallKitManager : NSObject

+ (EMCallKitManager *)shared;

- (void)enableCallKit;

- (BOOL)hasAnswerAction;

- (void)setCallKitAnswer:(BOOL)isSuccessed;

- (void)endCall;

// 处理通话记录对应的userActivity；
- (BOOL)handleCallUserActivity:(NSUserActivity *)userActivity;

// 存储日志
+ (void)saveString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
