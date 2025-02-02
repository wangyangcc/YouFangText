//
//  MMAppDelegateModel.m
//  Datakit
//
//  Created by wangyangyang on 15/5/26.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMAppDelegateModel.h"
#import "MetaData.h"
#import "MMAppDelegateHelper.h"

@implementation MMAppDelegateModel

- (id) init
{
    self = [super init];
    if (self)
    {
        _snsPlatformNames = @[UMShareToWechatSession, UMShareToWechatTimeline,UMShareToQQ];
    }
    
    return self;
}

- (NSString *)device_id
{
    if (_device_id == nil) {
        _device_id = [MetaData getToken];
        if (_device_id == nil || [_device_id length] <= 0 ) {
            _device_id = [MetaData getUid];
        }
    }
    return _device_id;
}

- (NSString *)messageUnreadNumber
{
    NSNumber *message_count = self.youwenUnreadNumber;
    NSInteger chatNewCount = 0;
    return [@([message_count integerValue] + chatNewCount) stringValue];
}

#pragma mark - 新手引导 和 广告图 判断

/**
 *  是否需要显示新手引导界面
 *
 *  @return 结果
 */
- (BOOL)needDisplayFirstUserGuide
{
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *firstSign = [[NSUserDefaults standardUserDefaults] objectForKey:[@"firstComing" stringByAppendingString:bundleVersion]];
    if (firstSign == nil || [firstSign length] == 0) {
        return YES;
    }
    return NO;
}

/**
 *  更新新手引导判断标示符，设置为不需要显示
 */
- (void)updateNotDisplayFirstUserGuide
{
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[@"firstComing" stringByAppendingString:bundleVersion]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  是否需要显示广告图界面
 *
 *  @return 结果
 */
- (BOOL)needDisplayStartImageView
{
    return YES;
}

#pragma mark - 第一次启动判断

/**
 *  供后台栏目入库使用
 *
 */
- (NSString *)firstLaunchStrSign
{
    NSString *firstLaunchStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppFisrtRequest"];
    if (firstLaunchStr == nil || [firstLaunchStr length] <= 0) {
        firstLaunchStr = @"1";
    }
    return firstLaunchStr;
}

/**
 *  供后台栏目入库使用，只在安装客户端第一次请求本接口时才传1，其余传0
 */
- (void)updateFirstLaunchStrSign:(NSString *)launchSign
{
    if (launchSign == nil) {
        launchSign = @"1";
    }
    //排除异常情况
    if ([launchSign isEqualToString:@"0"] == NO && [launchSign isEqualToString:@"1"] == NO) {
        launchSign = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:launchSign forKey:@"AppFisrtRequest"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
