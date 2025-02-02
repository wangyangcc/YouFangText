//
//  UIViewController+Login.h
//  Datakit
//
//  Created by wangyangyang on 15/5/26.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Login)

/**
 *  跳转到登录界面
 *
 *  @param callBackMethod 登录成功后的回调方法
 */
- (BOOL)isLoginCheckWtihCallBackMethod:(SEL)callBackMethod methodObj:(id)methodObj;

/**
 *  判断是否登录，并跳转到登录界面
 */
+ (BOOL)isLoginCheck;

@end
