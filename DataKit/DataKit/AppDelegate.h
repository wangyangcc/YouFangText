//
//  AppDelegate.h
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNavigationController.h"
#import "MMAppDelegateModel.h"
#import "MMTabbarController.h"
#import "MMPushManager.h"
#import "MMCheckAppUpdateHelper.h"
#import "UserGuidImageViewController.h"

@class DKUser;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  当前的nav
 */
@property (nonatomic, readonly) MLNavigationController   *rootNav;

/**
 *  当前的nav
 */
@property (nonatomic, readonly) MLNavigationController   *nav;

@property (nonatomic, readonly) MMTabbarController   *tabbarVC;

@property (strong, readonly, nonatomic) MMAppDelegateModel *appModel;

@property (nonatomic, strong, readonly) MMPushManager *pushManager;

@property (nonatomic, strong) MMCheckAppUpdateHelper *updateHelper;

@property (strong, nonatomic) UserGuidImageViewController *userGuid;//新手引导界面

/*!是否安装微信 */
@property (assign, nonatomic) BOOL isInstallWeiXin;
/*!是否安装QQ */
@property (assign, nonatomic) BOOL isInstallQQ;
/*!是否隐藏分享 */
@property (assign, nonatomic) BOOL isShowShare;

- (void)presentLoginVCWithAnimated:(BOOL)flag;

/**
 *  登录成功后调用
 */
- (void)loginSuccessWithUserModel:(DKUser *)userModel;
@end

