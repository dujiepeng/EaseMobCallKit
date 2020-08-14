//
//  LoginViewController.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/13.
//  Copyright © 2020 djp. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+Alert.h"
#import <Hyphenate/Hyphenate.h>
#import "ViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (EMClient.sharedClient.isLoggedIn) {
        [self presentTOCallView];
    }
}

- (IBAction)registAction:(id)sender {
    if (self.emIdTextField.text.length == 0 || self.pwdTextField.text.length == 0) {
        [self showError:@"请确认输入账号和密码"];
        return;
    }
    
    __block typeof(self) weakSelf = self;
    [self showHit:@"开始注册..."];
    [EMClient.sharedClient registerWithUsername:self.emIdTextField.text
                                       password:self.pwdTextField.text
                                     completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf hiddenHit];
        if (aError) {
            [weakSelf showToast:aError.errorDescription];
            return;
        }
        
        [weakSelf loginAction:nil];
    }];
}


- (IBAction)loginAction:(id)sender {
    if (self.emIdTextField.text.length == 0 || self.pwdTextField.text.length == 0) {
        [self showError:@"请确认输入账号和密码"];
        return;
    }
    
    [self showHit:@"开始登录..."];
    __block typeof(self) weakSelf = self;
    [EMClient.sharedClient loginWithUsername:self.emIdTextField.text
                                    password:self.pwdTextField.text
                                  completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf hiddenHitNow];
        if (aError) {
            [weakSelf showToast:aError.errorDescription];
            return;
        }

        [weakSelf presentTOCallView];
    }];
}

- (void)presentTOCallView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = vc;
    });
}


- (IBAction)bgTapAction:(id)sender {
    [self.view endEditing:YES];
}


@end
