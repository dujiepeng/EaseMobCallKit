//
//  UIViewController+Alert.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import "UIViewController+Alert.h"

#define kHITLABELTAG 10000001

@implementation UIViewController (Alert)
- (void)showError:(NSString *)aStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:aStr message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertC addAction:cancel];
        
        [self presentViewController:alertC animated:YES completion:nil];
    });
}


- (void)showTitle:(NSString *)aStr
          message:(NSString *)aMsg
       sureAction:(void(^)(void))sureCallback
           cancel:(void(^)(void))cancelCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:aStr
                                                                        message:aMsg
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
                                 {
            cancelCallback();
        }];
        [alertC addAction:cancel];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
                                 {
            sureCallback();
        }];
        
        [alertC addAction:action];
        [self presentViewController:alertC animated:YES completion:nil];
    });
    
}


- (void)showToast:(NSString *)aToastStr {
    [self showHit:aToastStr];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hiddenHit];
    });
}

- (void)showHit:(NSString *)hitStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view endEditing:YES];
        UILabel *hitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hitLabel.layer.masksToBounds = YES;
        hitLabel.layer.cornerRadius = 3;
        hitLabel.tag = kHITLABELTAG;
        hitLabel.backgroundColor = UIColor.blackColor;
        hitLabel.textColor = UIColor.whiteColor;
        hitLabel.numberOfLines = 0;
        hitLabel.textAlignment = NSTextAlignmentCenter;
        hitLabel.text = hitStr;
        [hitLabel sizeToFit];
        hitLabel.frame = CGRectInset(hitLabel.frame, -10, -5);
        hitLabel.alpha = 0;
        [self.view addSubview:hitLabel];
        hitLabel.center = self.view.center;
        [UIView animateWithDuration:0.3 animations:^{
            hitLabel.alpha = 0.9;
        }];
        
    });
}

- (void)hiddenHit {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [self.view viewWithTag:kHITLABELTAG];
        if (view) {
            [UIView animateWithDuration:1.0 animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                if (view) {
                    [view removeFromSuperview];
                }
            }];
        }
    });
}

- (void)hiddenHitNow {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [self.view viewWithTag:kHITLABELTAG];
        if (view) {
            [view removeFromSuperview];
        }
    });
}

@end
