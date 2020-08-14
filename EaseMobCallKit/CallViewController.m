//
//  CallViewController.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/13.
//  Copyright © 2020 djp. All rights reserved.
//

#import "CallViewController.h"
#import "EMCallKitManager.h"
#import "EMMessage+PushKit.h"


@interface CallViewController ()<EMCallManagerDelegate>
{
    NSTimer *_timer;
    int _time;
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;


@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.callSession.remoteName;
    [self.timeLabel setHidden:YES];
    
    [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
    
    if (self.callSession.isCaller) {
        self.answerBtn.hidden = YES;
    }
}

- (void)dealloc {
    [EMClient.sharedClient.callManager removeDelegate:self];
}

- (void)answerCall {
    [self startTimer];
    EMError *error = [EMClient.sharedClient.callManager answerIncomingCall:self.callSession.callId];
    [self.answerBtn setHidden:YES];
    [self.timeLabel setHidden:NO];
    if ([[EMCallKitManager shared] hasAnswerAction]) {
        [[EMCallKitManager shared] setCallKitAnswer: error == nil];
    }
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer timerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateTimeLabel)
                                   userInfo:nil
                                    repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _time = 0;
    }
}

- (void)updateTimeLabel {
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d", _time/60, _time];
    self.timeLabel.text = timeStr;
    _time++;
}


- (IBAction)hangupAction:(id)sender {
    
    // [EMMessage sendCancelPushKitMessageToUser:self.callSession.remoteName];
    [EMClient.sharedClient.callManager endCall:self.callSession.callId
                                        reason:EMCallEndReasonHangup];
    
}

- (IBAction)answerAction:(id)sender {
    [self answerCall];
}

#pragma mark - EMCallManagerDelegate

- (void)callDidAccept:(EMCallSession *)aSession {
    [self.timeLabel setHidden:NO];
    [self startTimer];
}

// 挂断
- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError {
    [self stopTimer];
    [[EMCallKitManager shared] endCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = [[EMClient sharedClient].callManager getCallOptions].offlineMessageText;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{@"em_apns_ext":@{@"em_push_title":text}}];
    message.chatType = EMChatTypeChat;
    message.ext = @{
        @"em_apns_ext":@{
                @"em_push_sound":@"soundName"
        }
    };
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}


@end
