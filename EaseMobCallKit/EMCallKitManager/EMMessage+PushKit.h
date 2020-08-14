//
//  EMMessage+PushKit.h
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/13.
//  Copyright © 2020 djp. All rights reserved.
//

#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMMessage (PushKit)
+ (void)sendPushKitCallMessageToUser:(NSString *)aUsername
                          myNickname:(NSString *)aNickname;

+ (void)sendCancelPushKitMessageToUser:(NSString *)aUsername;
@end

NS_ASSUME_NONNULL_END
