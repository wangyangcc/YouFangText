//
//  MMPushManager.m
//  Datakit
//
//  Created by wangyangyang on 15/7/21.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMPushManager.h"
#import "JSONKit.h"
#import "MMAppDelegateHelper.h"

@interface MMPushManager () 
{
    BOOL getuiStart;/**< 个推是否启动 */
}

@property (nonatomic, copy) NSString *clientId;

@property (nonatomic, strong) YAPushInfoObject *awaitPushInfo; /**< 等待处理的推送的对象 */

@end

@implementation MMPushManager

/**
 *  注册通知
 */
+ (void)registerForNotifications
{
    //注册消息通知
    if (([[UIDevice currentDevice] systemVersion].floatValue >= 8.0)) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }
}

/**
 *  取消注册通知
 */
+ (void)unRegisterForNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

/**
 *  tokendata 转换为字符串
 *
 *  @param tokenData tokendata
 *
 *  @return 字符串
 */
+ (NSString *)convertDataToString:(NSData *)tokenData
{
    if (tokenData == nil) {
        return @"";
    }
    NSString *dt = [[tokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&lt;&gt;"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    dt = [dt stringByReplacingOccurrencesOfString:@"<" withString:@""];
    dt = [dt stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return dt;
}

/**
 *  更新推送令牌
 *
 *  @param tokenStr 推送令牌
 */
+ (void)updatePushToken:(NSString *)tokenStr
{
    if (tokenStr == nil || [tokenStr length] <= 0) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:tokenStr forKey:kPushManagerTokenStringValue];
    [userDefaults synchronize];
    
#if DEBUG
    NSLog(@"MMPushManager---updatePushToken----%@",tokenStr);
#endif
    
    //[3]:向个推服务器注册deviceToken

}

/**
 *  注册推送失败
 */
+ (void)didFailToRegisterForRemote
{
    // [3-EXT]:如果APNS注册失败，通知个推服务器

}

/**
 *  获得推送令牌
 *
 *  @return 推送令牌
 */
+ (NSString *)getPushToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:kPushManagerTokenStringValue];
    return [NSString stringWithFormat:@"%@",token?:@""];
}

/**
 *  进入后台
 */
- (void)enterBackground
{
    // [EXT] APP进入后台时，通知个推SDK进入后台

    getuiStart = NO;
}

/**
 *  注册个推
 */
- (void)startGeTuiSdk
{
    NSError *err =nil;
    if (getuiStart) {
        return;
    }
    
    //[1-1]:通过 AppId、appKey 、appSecret 启动SDK
    if (err) {
        NSLog(@"MMPushManager---个推启动失败---%@",err);
    }
    else {
        getuiStart = YES;
    }
    //[1-2]:设置是否后台运行开关
    //[GeTuiSdk runBackgroundEnable:YES];
    //self.clientId = [GeTuiSdk clientId];
    
}

/**
 *  收到推送消息
 *
 *  @param userInfo       推送消息
 *  @param isDisplayAlert 是否显示alertView
 */
- (void)receiveRemoteNotification:(NSDictionary *)userInfo
                   isDisplayAlert:(BOOL)isDisplayAlert
{
    NSLog(@"MMPushManager----didFinishLaunchingWithOptions----%@",userInfo);
    YAPushInfoObject *pushModel = nil;
    @try {
        //判断是否是云通讯那边的消息
        if (userInfo && [[userInfo allKeys] containsObject:@"receiver"] && [[userInfo allKeys] containsObject:@"sender"]) {
            pushModel = [YAPushInfoObject new];
            pushModel.chatReceiver = [userInfo objectForKey:@"receiver"];
            pushModel.chatSender = [userInfo objectForKey:@"sender"];
            pushModel.pushType = @"-1";
            pushModel.pushTitle = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            //获取当前时间槽
            time_t now;
            time(&now);
            NSString *time_stamp = [NSString stringWithFormat:@"%ld", now];
            //end
            pushModel.pushId = @([time_stamp integerValue]);
            pushModel.displayAlertView = YES;
        }
        //end
        else {
            NSError *error = nil;
            pushModel = [MTLJSONAdapter modelOfClass:NSClassFromString(@"YAPushInfoObject") fromJSONDictionary:userInfo error:&error];
            pushModel.displayAlertView = isDisplayAlert;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"MMPushManager---receiveRemoteNotification---解析失败---%@",userInfo);
    }
    
    //说明是从启动应用进入的
    if (pushModel.displayAlertView == NO && self.awaitPushInfo == nil) {
        self.awaitPushInfo = pushModel;
    }
    else if (self.awaitPushInfo == nil) {
        self.awaitPushInfo = pushModel;
    }
}

/**
 *  启动接口调用成功后调用
 */
- (void)loginCheckDoneNotification
{
    NSLog(@"MMPushManager---loginCheckDoneNotification---");
    if (self.awaitPushInfo) {
        [self receiveMessageWithInfo:self.awaitPushInfo];
        [self performSelector:@selector(setAwaitPushInfo:) withObject:nil afterDelay:1];
    }
}

/**
 *  清空新消息数量
 */
- (void)clearApplicationIconBadgeNumber
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)receiveMessageWithInfo:(YAPushInfoObject *)pushInfo
{
    [self.c_delegate performSelector:@selector(pushManagerReceiveMessageWithInfo:) withObject:pushInfo];
}

#pragma mark - getters and setters

- (void)setClientId:(NSString *)clientId
{
    if (_clientId) {
        _clientId = nil;
    }
    _clientId = clientId;
    //[self.clientRequest notifyGeTuiClientId:clientId userId:userId];
}

@end

@implementation YAPushInfoObject

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"pushType" : @"type",
             
             @"pushTitle" : @"title",
             
             @"createUserName" : @"create_user_name",
             
             @"userId" : @"user_id",
             
             @"questionId" : @"question_id",
             
             @"answerId" : @"answer_id",
             
             @"pushId" : @"gr_id",
            
             };
}

@end
