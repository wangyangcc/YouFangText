//
//  MMAppDelegateModel.h
//  Datakit
//
//  Created by wangyangyang on 15/5/26.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MMAppDelegateModel : NSObject

//分享的平台
@property (strong, nonatomic) NSArray *snsPlatformNames;

@property (nonatomic, copy) NSString *u_sectionId;

/**
 *  用户位置
 */
@property (assign, nonatomic) CLLocationCoordinate2D userLocation;

/**
 *  有token时，取推送的token，否则取uuid
 */
@property (nonatomic, copy) NSString *device_id;

/**
 *  有问方面消息未读数量
 */
@property (nonatomic, copy) NSNumber *youwenUnreadNumber;

/**
 *  消息中心未读数量(包括聊天)
 */
@property (nonatomic, copy) NSString *messageUnreadNumber;

#pragma mark - 新手引导 和 广告图 判断

/**
 *  是否需要显示新手引导界面
 *
 *  @return 结果
 */
- (BOOL)needDisplayFirstUserGuide;

/**
 *  更新新手引导判断标示符，设置为不需要显示
 */
- (void)updateNotDisplayFirstUserGuide;

/**
 *  是否需要显示广告图界面
 *
 *  @return 结果
 */
- (BOOL)needDisplayStartImageView;

#pragma mark - 第一次启动判断

/**
 *  供后台栏目入库使用
 *
 */
- (NSString *)firstLaunchStrSign;

/**
 *  供后台栏目入库使用，只在安装客户端第一次请求本接口时才传1，其余传0
 */
- (void)updateFirstLaunchStrSign:(NSString *)launchSign;

@end
