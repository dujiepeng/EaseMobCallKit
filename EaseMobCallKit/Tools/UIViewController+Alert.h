//
//  UIViewController+Alert.h
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Alert)
- (void)showError:(NSString *)aStr;

- (void)showTitle:(NSString *)aStr
          message:(NSString *)aMsg
       sureAction:(void(^)(void))sureCallback
           cancel:(void(^)(void))cancelCallback;

- (void)showToast:(NSString *)aToastStr;
- (void)showHit:(NSString *)hitStr;
- (void)hiddenHit;
- (void)hiddenHitNow;

@end

NS_ASSUME_NONNULL_END
