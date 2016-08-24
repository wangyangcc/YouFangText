//
//  MMCheckAppUpdateHelper.m
//  Datakit
//
//  Created by wangyangyang on 15/7/14.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMCheckAppUpdateHelper.h"
#import "DKClientRequest.h"
#import "NSString+URLEncoding.h"

@interface MMCheckAppUpdateHelper () <MMAlertManageDelegate, DKClientRequestCallBackDelegate>
{
    BOOL displayAlert;/** 是否显示提示框 */
}

@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *updateMode;
@property (nonatomic, strong) DKClientRequest *clientRequest;

@property (nonatomic, copy) NSString *helpUrlPath;
@property (nonatomic, copy) NSString *aboutUrlPath;

@end

@implementation MMCheckAppUpdateHelper

- (void)beginCheck
{
    displayAlert = YES;
    [self.clientRequest checkAppUpdate];
}

/**
 *  得到帮助的网址
 */
- (NSString *)getHelpUrlPath
{
    return @"http://mp.weixin.qq.com/s?__biz=MzIxODExNTU2NA==&mid=2650183905&idx=1&sn=b8812c6ac473e0b784cac1b37c6675c5";
//    if (self.helpUrlPath == nil || [self.helpUrlPath length] <= 0) {
//        displayAlert = NO;
//        [self.clientRequest checkAppUpdate];
//        return nil;
//    }
//    return self.helpUrlPath;
}

/**
 *  得到关于的网址
 */
- (NSString *)getAboutUrlPath
{
    return @"http://www.datakit.cc";
//    if (self.aboutUrlPath == nil || [self.aboutUrlPath length] <= 0) {
//        displayAlert = NO;
//        [self.clientRequest checkAppUpdate];
//        return nil;
//    }
//    return self.aboutUrlPath;
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    @try {
        [UALogger log:@" resultBlock callBack 开始调用"];
        NSDictionary *resultDic = clientRequest.responseObject;
        self.helpUrlPath = resultDic[@"helpUrl"];
        self.aboutUrlPath = resultDic[@"aboutUrl"];
        
        //判断是否成功
        if ([resultDic[@"isSuccess"] boolValue] == NO || displayAlert == NO) {
            return;
        }
        //end
        NSString *newTitle = [resultDic objectForKey:@"versionDesc"];
        
        NSString *mode = [resultDic objectForKey:@"mode"];
        self.updateMode = mode;
        NSString *url = [resultDic objectForKey:@"url"];
        self.downloadUrl = url;
        NSString *content = [resultDic objectForKey:@"releaseNotes"];
        
        //0-静默模式
        if ([mode integerValue] == 0) {
            return;
        }
        //1-弹窗提示模式
        else if ([mode integerValue] == 2) {
            MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:newTitle message:content delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去升级", nil];
            [alertManage show];
        }
        //2-强制升级模式
        else if ([mode integerValue] == 1) {
            MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:newTitle message:content delegate:self cancelButtonTitle:nil otherButtonTitles:@"去升级", nil];
            [alertManage show];
        }
        [UALogger log:@" resultBlock callBack 调用结束"];
    }
    @catch (NSException *exception) {
        NSLog(@"MMCheckAppUpdateHelper------解析数据失败");
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    self.clientRequest = nil;
}

#pragma mark - MMAlertManageDelegate

- (void)alertView:(MMAlertManage *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //1-弹窗提示模式
    if ([self.updateMode integerValue] == 2 && alertView.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
    
    //2-强制升级模式
    if ([self.updateMode integerValue] == 1) {
        //强制退出
        _exit(0);
    }
}

#pragma mark - getters and setters

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [DKClientRequest new];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

@end
