//
//  UIViewController+Login.m
//  Datakit
//
//  Created by wangyangyang on 15/5/26.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "UIViewController+Login.h"
#import "MMAppDelegateHelper.h"

@implementation UIViewController (Login)

/**
 *  跳转到登录界面
 *
 *  @param callBackMethod 登录成功后的回调方法
 */
- (BOOL)isLoginCheckWtihCallBackMethod:(SEL)callBackMethod methodObj:(id)methodObj
{
    if ([[MMAppDelegateHelper shareHelper] currentUser]) {
        return YES;
    }
    __weak UIViewController *weakSelf = self;
//    //用户登录界面
//    [UIViewController triggerRoute:OPEN_USERLOGIN_PAGE withParameters:@{@"callBack" : ^(NSInteger receivedSize) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        if (callBackMethod) {
//            [weakSelf performSelector:callBackMethod withObject:methodObj];
//        }
//#pragma clang diagnostic pop
//    }}];
    
    return NO;
}

/**
 *  判断是否登录，并跳转到登录界面
 */
+ (BOOL)isLoginCheck
{
    if ([[MMAppDelegateHelper shareHelper] currentUser]) {
        return YES;
    }
//    //用户登录界面
//    [UIViewController triggerRoute:OPEN_USERLOGIN_PAGE withParameters:@{@"callBack" : ^(NSInteger receivedSize) {
//    }}];
    
    return NO;
}

@end
