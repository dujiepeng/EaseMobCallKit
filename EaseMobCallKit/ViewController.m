//
//  ViewController.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+Alert.h"
#import "EMMessage+PushKit.h"
#import <Hyphenate/Hyphenate.h>

#import "CallViewController.h"


@interface ViewController () <EMCallManagerDelegate, EMCallBuilderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
    [EMClient.sharedClient.callManager setBuilderDelegate:self];
    
    [self setupCallOptions];
}


- (void)setupCallOptions
{
    EMCallOptions *callOptions = [EMClient.sharedClient.callManager getCallOptions];

    // 设置对方即使不在线时回调
    callOptions.isSendPushIfOffline = YES;
    [EMClient.sharedClient.callManager setCallOptions:callOptions];
}

- (void)dealloc {
    [EMClient.sharedClient.callManager removeDelegate:self];
    [EMClient.sharedClient.callManager setBuilderDelegate:nil];
}

- (IBAction)callAction:(UIButton *)btn {
    if (self.emIdTextField.text.length == 0) {
        [self showError:@"请输入对方id"];
        return;
    }
    
    __block typeof(self) weakSelf = self;
    
    [EMClient.sharedClient.callManager startCall:EMCallTypeVoice
                                      remoteName:self.emIdTextField.text
                                             ext:nil
                                      completion:^(EMCallSession *aCallSession, EMError *aError)
    {
        if (aError) {
            [weakSelf showError:aError.errorDescription];
            return;
        }
        
        // 语音呼叫成功，弹出呼叫页面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CallViewController *callVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
        callVC.modalPresentationStyle = 0;
        callVC.callSession = aCallSession;
        [weakSelf presentViewController:callVC animated:YES completion:nil];
    }];
}


- (IBAction)bgTapAction:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)logoutAction:(id)sender {
    [self showHit:@"正在退出..."];
    [EMClient.sharedClient logout:YES completion:^(EMError *aError) {
        [self hiddenHit];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = vc;
    }];
}


#pragma mark - EMCallManagerDelegate
// 收到呼叫，跳转到语音页面
- (void)callDidReceive:(EMCallSession *)aSession {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callVC.modalPresentationStyle = 0;
    callVC.callSession = aSession;
    [self presentViewController:callVC animated:YES completion:nil];
}


#pragma mark - EMCallBuilderDelegate
/**
 当被叫方不在线时，设置EMCallOptions isSendPushIfOffline属性为YES和
 注册[EMClient.sharedClient.callManager setBuilderDelegate:self] 后会收到该回调。
 
 aRemoteName: 对方的环信id
 */
- (void)callRemoteOffline:(NSString *)aRemoteName {
    // 收到此回调表示对方不在线，可以发送消息，并设置PushKit推送。
    [EMMessage sendPushKitCallMessageToUser:aRemoteName
                                 myNickname:self.nickTextField.text];
}

@end
