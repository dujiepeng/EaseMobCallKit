//
//  EMCallKitManager.m
//  EaseMobCallKit
//
//  Created by 杜洁鹏 on 2020/8/12.
//  Copyright © 2020 djp. All rights reserved.
//

#import "EMCallKitManager.h"
#import <PushKit/PushKit.h>
#import <Hyphenate/Hyphenate.h>
#import <Hyphenate/EMOptions+PrivateDeploy.h>

#import "CallViewController.h"

NSString *publicCallId; // 主叫方的环信id
BOOL publicIsAnswer; // 这则呼叫是否被接起

static EMCallKitManager * EMCallKitManager_;

@interface EMCallKitManager () <PKPushRegistryDelegate, CXProviderDelegate, EMCallManagerDelegate>
{
    dispatch_queue_t _pushkitQueue;
    
}


@property (nonatomic, strong) CXAnswerCallAction *answerAction;

@property (nonatomic, strong) CXProviderConfiguration *providerConfiguration;
@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) NSUUID *currentCall;


@end

@implementation EMCallKitManager
+ (EMCallKitManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        EMCallKitManager_ = [[EMCallKitManager alloc] init];
    });
    
    return EMCallKitManager_;
}


- (instancetype)init
{
    if (self = [super init])
    {
        _pushkitQueue = dispatch_queue_create("com.easemob.pushkit.queue", DISPATCH_QUEUE_SERIAL);
        [EMClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - public
- (void)enableCallKit
{
    PKPushRegistry *pushKit = [[PKPushRegistry alloc] initWithQueue:_pushkitQueue];
    pushKit.delegate = self;
    pushKit.desiredPushTypes = [NSSet setWithObjects:PKPushTypeVoIP, nil];
}

- (BOOL)handleCallUserActivity:(NSUserActivity *)userActivity
{
    return NO;
}

- (BOOL)hasAnswerAction {
    return _answerAction != nil;
}

- (void)setCallKitAnswer:(BOOL)isSuccessed {
    if (isSuccessed) {
        [_answerAction fulfill];
    }else {
        [_answerAction fail];
    }
}

- (void)endCall {
    if (_callController) {
        CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:self.currentCall];
        [_callController requestTransactionWithAction:action
                                           completion:^(NSError * _Nullable error)
        {
            
        }];
        _callController = nil;
    }
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type
{
    // 将收到的pushkit token传给环信
    [EMClient.sharedClient registerPushKitToken:pushCredentials.token completion:nil];
    NSLog(@"获取到pushkit token");
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    NSLog(@"获取pushkit token 失败");
}


- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion
{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload.dictionaryPayload options:0 error:0];
    NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [EMCallKitManager saveString:dataStr];
    
    /*
     e中的内容为发送方填入ext:custom中的内容
     {
         "m": "772299818058910052",
         "t": "du001",
         "aps": {
             "badge": 2,
             "alert": {
                 "body": "您有一条新消息"
             },
             "sound": "default"
         },
         "e": {
             "action": "call",
             "callId": "du002"
         },
         "f": "du002"
     }
     */

    NSDictionary *pushInfo = payload.dictionaryPayload[@"e"];
    NSString *nickname = pushInfo[@"nickname"];
    publicCallId = pushInfo[@"caller"];
    BOOL isVideo = [pushInfo[@"video"] boolValue];
    NSString *action = pushInfo[@"action"];
    
    if (!pushInfo) {
        completion();
        return;
    }

    
    if ([action isEqualToString:@"call"]) {
        [self _makcCallComingWithEmId:publicCallId nickname:nickname isVideo:isVideo];
    }else if ([action isEqualToString:@"hangup"]) {
        [self _hangupWithCallId:publicCallId];
    }
    
    completion();
}



#pragma mark - CXProviderDelegate
- (void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"providerDidReset:%@",provider);
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    publicIsAnswer = YES;
    _answerAction = action;
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession
{
    
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession
{
    
}


#pragma mark - EMCallManagerDelegate
- (void)callDidReceive:(EMCallSession *)aSession {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callVC.modalPresentationStyle = 0;
    callVC.callSession = aSession;
    UIApplication *app = [UIApplication sharedApplication];
    UIViewController *rootVC = app.delegate.window.rootViewController;
    [rootVC presentViewController:callVC animated:YES completion:nil];
    if ([aSession.remoteName isEqualToString:publicCallId] && publicIsAnswer) {
        [callVC answerCall];
    }
}

#pragma - mark private
// 有电话呼入
- (void)_makcCallComingWithEmId:(NSString *)emId
                       nickname:(NSString *)aNickname
                        isVideo:(BOOL)isVideo {
    self.provider = [[CXProvider alloc] initWithConfiguration:self.providerConfiguration];
    [self.provider setDelegate:self queue:dispatch_get_main_queue()];
    _callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    
    CXCallUpdate* update = [self callUpdateWithRemoteHandleValue:emId video:isVideo localName:aNickname];
    
    //弹出电话页面
    [self.provider reportNewIncomingCallWithUUID:self.currentCall
                                          update:update
                                      completion:^(NSError * _Nullable error) {
        
    }];
}

// 接起前对方挂断
- (void)_hangupWithCallId:(NSString *)aCallId {
    if ([publicCallId isEqualToString:aCallId]) {
        [self.provider reportCallWithUUID:self.currentCall endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
        self.currentCall = nil;
    }
}


// 电话呼出
- (void)_makcOutgoingWithEmId:(NSString *)emId
                    isVideo:(BOOL)isVideo {
    
   // TODO: 1. 根据id找到被叫方的nickname; 2. 使用app呼出页面;
}



- (CXCallUpdate *)callUpdateWithRemoteHandleValue:(NSString *)aValue video:(BOOL)isVideo localName:(NSString *)aNickname{
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.supportsDTMF = false;
    update.supportsHolding = false;
    update.supportsGrouping = false;
    update.supportsUngrouping = false;
    update.hasVideo = isVideo;
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:aValue];
    update.localizedCallerName = aNickname;
    self.currentCall = [NSUUID UUID];
    return update;
}


- (NSString *)_dataToString:(NSData *)aData {
    NSMutableString *strToken = [NSMutableString string];
    const char *bytes = aData.bytes;
    NSUInteger iCount = aData.length;
    for (int i = 0; i < iCount; i++) {
        [strToken appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    
    return strToken;
}


#pragma mark - getter
- (CXProviderConfiguration *)providerConfiguration {
    if (!_providerConfiguration) {
        _providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"环信"];
        _providerConfiguration.supportsVideo = YES;
        _providerConfiguration.maximumCallsPerCallGroup = 1;
        _providerConfiguration.maximumCallGroups = 1;
        // CXHandleTypePhoneNumber, CXHandleTypeGeneric, CXHandleTypeEmailAddress
        _providerConfiguration.supportedHandleTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInt:CXHandleTypeGeneric], nil];
        UIImage* iconMaskImage = [UIImage imageNamed:@"AppIcon"];
        _providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation(iconMaskImage);
    }
    return _providerConfiguration;
}



+ (void)saveString:(NSString *)str {
    NSString *homeDir = NSHomeDirectory();
    NSLog(@"homeDir = %@",homeDir);
    
    //在某个范围内搜索文件夹的路径.
    //directory:获取哪个文件夹
    //domainMask:在哪个路径下搜索
    //expandTilde:是否展开路径.
    
    //这个方法获取出的结果是一个数组.因为有可以搜索到多个路径.
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //在这里,我们指定搜索的是Cache目录,所以结果只有一个,取出Cache目录
    NSString *cachePath = array[0];
    NSLog(@"%@",cachePath);
    //拼接文件路径
    NSString *filePathName = [cachePath stringByAppendingPathComponent:@"Log.txt"];
    
    NSString *writeTime = [@"\n" stringByAppendingString:[@"=======================\n" stringByAppendingString:[[self getCurrentTime] stringByAppendingString:@"\n"]]];
    
    NSString *writeTotext = [@"\n" stringByAppendingString:@"======================="];
    
    
    writeTime = [[writeTime stringByAppendingString:str]
                 stringByAppendingString:writeTotext];
    
    NSLog(@"%@",writeTime);
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathName]) {
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathName];
        
        [fileHandle seekToEndOfFile]; //将节点跳到文件的末尾
        
        NSData *stringData = [writeTime dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle writeData:stringData]; // 追加写入数据
        
        [fileHandle closeFile];
    } else {
        
        [writeTime writeToFile:filePathName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];//yyyy-MM-dd-hh-mm-ss
    [formatter setDateFormat:@"yyyy:MM:dd hh:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}


@end
