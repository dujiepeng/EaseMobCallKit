//
//  EMMessage+PushKit.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/13.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EMMessage+PushKit.h"
#import <Hyphenate/Hyphenate.h>

@implementation EMMessage (PushKit)
+ (void)sendPushKitCallMessageToUser:(NSString *)aUsername
                          myNickname:(NSString *)aNickname
{
    NSString *currentUsername = EMClient.sharedClient.currentUsername;
    NSString *nickName = aNickname;
    if (nickName && nickName.length > 0) { // 如果传过来的nickname是空，则使用当前登录的环信id
        nickName = currentUsername;
    }
    // 构造消息并发送
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:[nickName stringByAppendingString:@"邀请您进行语音通话"]];
    EMMessage *msg = [[EMMessage alloc] initWithConversationID:aUsername
                                                          from:currentUsername
                                                            to:aUsername
                                                          body:body
                                                           ext:nil];
    
    
    
    /**
     ext中，关键字和格式固定，需要为如下格式，其中type必须为call
     {
        @{@"em_push_ext" : @{
                  @"type":@"call",
                  @"custom":@{
                        @"xxx":@"xxxx"
                  }
            }
        };
     }
     */
    msg.ext = ({
        @{@"em_push_ext" : @{
                  @"type":@"call",
                  @"custom":@{
                        @"nickname": nickName ?: @"",
                        @"caller":currentUsername,
                        @"action":@"call",
                  }
            }
        };
    });
    
    [EMClient.sharedClient.chatManager sendMessage:msg progress:nil completion:nil];
}

// 作为呼叫时挂断使用，因为ios13特性，可能会导致不会再被呼起，暂时未调用
+ (void)sendCancelPushKitMessageToUser:(NSString *)aUsername
{
    NSString *currentUsername = EMClient.sharedClient.currentUsername;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"结束通话"];
    EMMessage *msg = [[EMMessage alloc] initWithConversationID:aUsername
                                                          from:currentUsername
                                                            to:aUsername
                                                          body:body
                                                           ext:nil];
    
    msg.ext = ({
        @{
            @"em_push_ext":@{
                    @"type":@"call",
                    @"custom":@{
                            @"caller":currentUsername,
                            @"action":@"hangup",
                    }
            }
        };
    });
    
    [EMClient.sharedClient.chatManager sendMessage:msg progress:nil completion:nil];
}
@end
