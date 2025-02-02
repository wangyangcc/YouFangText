//
//  MMPushManager.h
//  Datakit
//
//  Created by wangyangyang on 15/7/21.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

static NSString * const kPushManagerTokenStringValue = @"kPushManagerTokenStringValue";

@protocol MMPushManagerDelegate;
@interface MMPushManager : NSObject

/**
 *  个推的 clientId
 */
@property (nonatomic, readonly, copy) NSString *clientId;

@property (nonatomic, weak) id<MMPushManagerDelegate> c_delegate;

/**
 *  注册通知
 */
+ (void)registerForNotifications;

/**
 *  取消注册通知
 */
+ (void)unRegisterForNotifications;

/**
 *  tokendata 转换为字符串
 *
 *  @param tokenData tokendata
 *
 *  @return 字符串
 */
+ (NSString *)convertDataToString:(NSData *)tokenData;

/**
 *  更新推送令牌
 *
 *  @param tokenStr 推送令牌
 */
+ (void)updatePushToken:(NSString *)tokenStr;

/**
 *  注册推送失败
 */
+ (void)didFailToRegisterForRemote;

/**
 *  获得推送令牌
 *
 *  @return 推送令牌
 */
+ (NSString *)getPushToken;

/**
 *  进入后台
 */
- (void)enterBackground;

/**
 *  注册个推
 */
- (void)startGeTuiSdk;

/**
 *  收到推送消息
 *
 *  @param userInfo       推送消息
 *  @param isDisplayAlert 是否显示alertView
 */
- (void)receiveRemoteNotification:(NSDictionary *)userInfo
                   isDisplayAlert:(BOOL)isDisplayAlert;

/**
 *  启动接口调用成功后调用
 */
- (void)loginCheckDoneNotification;

/**
 *  清空新消息数量
 */
- (void)clearApplicationIconBadgeNumber;

@end

@interface YAPushInfoObject : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *pushType;

@property (nonatomic, copy) NSString *pushTitle;

@property (nonatomic, copy) NSString *createUserName;

@property (nonatomic, copy) NSNumber *userId;

@property (nonatomic, copy) NSNumber *questionId;

@property (nonatomic, copy) NSNumber *answerId;

@property (nonatomic, assign) BOOL displayAlertView;

@property (nonatomic, copy) NSNumber *pushId;/**< 区别每次推送任务的id */

@property (nonatomic, copy) NSString *chatReceiver; /**< 聊天的接受者 */

@property (nonatomic, copy) NSString *chatSender; /**< 聊天的接受者 */

@end

@protocol MMPushManagerDelegate <NSObject>

/**
 *  显示 alertview
 *
 *  @param pushInfo 推送消息对象
 */
- (void)pushManagerReceiveMessageWithInfo:(YAPushInfoObject *)pushInfo;

@end
