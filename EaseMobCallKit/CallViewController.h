//
//  CallViewController.h
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/13.
//  Copyright © 2020 djp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallViewController : UIViewController

@property (nonatomic, strong) EMCallSession *callSession;
@property (nonatomic, strong) NSString *nickname;
- (void)answerCall;
@end

NS_ASSUME_NONNULL_END
