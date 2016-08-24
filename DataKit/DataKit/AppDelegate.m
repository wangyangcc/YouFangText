//
//  AppDelegate.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"

#import "SVProgressHUD.h"
#import "MMAppDelegateHelper.h"
#import "DKSocketRequestHelper.h"
#import <TencentOpenAPI/QQApiInterface.h>

@interface AppDelegate() <UITabBarControllerDelegate, MMPushManagerDelegate, MMAlertManageDelegate>
{
    YAPushInfoObject *previousPushInfo; /**< 上一个推送的对象 */
    
    BOOL updated;
}

@property (strong, nonatomic) MMAppDelegateModel *appModel;
@property (nonatomic, strong) MMPushManager *pushManager;

@property (nonatomic, strong) MMTabbarController   *tabbarVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self myInitController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    [self addFirstGuide];
    //通知相关
//    [MMPushManager registerForNotifications];
//    [self.pushManager startGeTuiSdk];
    //end

    //获取通知消息
    if (launchOptions) {
        NSDictionary *pushMessage = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self.pushManager receiveRemoteNotification:pushMessage isDisplayAlert:NO];
#if DEBUG
        NSLog(@"MMPushManager----didFinishLaunchingWithOptions----%@",pushMessage);
#endif
    }
    //end
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //设置提示框属性
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:121/255.0 green:126/255.0 blue:137/255.0 alpha:0.9]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        //end
        
        [WXApi registerApp:WeiChatKey];
        
//        [UMSocialWechatHandler setWXAppId:WeiChatKey appSecret:WeiChatSecretKey url:nil];
//        [UMSocialConfig setSnsPlatformNames:self.appModel.snsPlatformNames];
//        
//        //设置分享到QQ/Qzone的应用Id，和分享url 链接
//        [UMSocialQQHandler setQQWithAppId:Tencent_AppId appKey:Tencent_AppKey url:@"http://www.umeng.com/social"];
//        //end
//        
//        //对未安装客户端平台进行隐藏
//        [UMSocialConfig hiddenNotInstallPlatforms:nil];
        
        [UALogger setShouldLogInProduction:YES];
    });
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.pushManager enterBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[EXT] 重新上线
    [self.pushManager startGeTuiSdk];
    [self.pushManager clearApplicationIconBadgeNumber];
    //检查版本
    if (updated == NO) {
        [self.updateHelper beginCheck];
        updated = YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.pushManager clearApplicationIconBadgeNumber];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.pushManager clearApplicationIconBadgeNumber];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([[MetaData getPlatform] rangeOfString:@"iPad"].location != NSNotFound)
        return UIInterfaceOrientationMaskPortrait;
    else  /* iphone */
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqualToString:WeiChatKey]) {
//        UIViewController *selfTop = [self.nav topViewController];
//        if ([selfTop conformsToProtocol:@protocol(WXApiDelegate)]) {
//            return [WXApi handleOpenURL:url delegate:nil];
//        }
        return [WXApi handleOpenURL:url delegate:nil];
    }
//    UIViewController *selfTop = [self.nav topViewController];
    return [QQApiInterface handleOpenURL:url delegate:nil];
}

#pragma mark - 推送相关

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 3
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        // 4
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [MMPushManager convertDataToString:deviceToken];
#ifdef IS_DEBUG_MODEL
    NSLog(@"deviceTokenStr---------%@",deviceTokenStr);
#endif
    
#ifdef DEBUG
    NSLog(@"");
#else
    if ([deviceTokenStr length] > 0)
    {
       // [MMPushManager updatePushToken:deviceTokenStr];
    }
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken----release");
#endif
    
#ifdef IS_DEBUG_MODEL
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken---------register");
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"deviceTokenStr---error------%@",error);
    [MMPushManager didFailToRegisterForRemote];
}

//接受消息推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#if DEBUG
    NSLog(@"pushMessage----didFinishLaunchingWithOptions----%@",userInfo);
#endif
    @try {
        //        //处理苹果通道数据
        //        NSMutableDictionary *userInfoTmp = [userInfo mutableCopy];
        //        [userInfoTmp setValue:[[userInfoTmp objectForKey:@"aps"] objectForKey:@"alert"] forKey:@"title"];
        //        //end
        [self.pushManager receiveRemoteNotification:userInfo isDisplayAlert:NO];
    }
    @catch (NSException *exception) {
#if DEBUG
        NSLog(@"pushMessage----didFinishLaunchingWithOptions---解析失败----%@",userInfo);
#endif
    }
    @finally {
        
    }
}

#pragma mark -
#pragma mark - custom method

/**
 *  添加新手引导或者启动图
 */
- (void)addFirstGuide
{
    
    UIView *displayView = [[UIApplication sharedApplication] keyWindow];
    
    //添加偏好设置
    BOOL isDisplayStartImageView = YES;
    //添加新手引导
    if ([self.appModel needDisplayFirstUserGuide]) {
        isDisplayStartImageView = NO;
        //添加新手引导界面
        self.userGuid = [[UserGuidImageViewController alloc] init];
        self.userGuid.view.frame = displayView.bounds;
        [displayView addSubview:self.userGuid.view];
        [self.userGuid.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
//    //判断是否添加广告图，只有偏好设置和新手引导都显示完后才添加
//    if (isDisplayStartImageView && [self.appModel needDisplayStartImageView]) {
//        YAStartImageView *startView = [[YAStartImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight + (IOS7AFTER ? 0 : 20))];
//        [displayView addSubview:startView];
//    }
    
//    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:[NSClassFromString(@"DKRegisterViewController") new]];
//    [MMAppDelegate.nav presentViewController:nav animated:NO completion:NULL];
//    return;
    
    //判断用户是否登录
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    if (user == nil) {
        [self presentLoginVCWithAnimated:NO];
    }
    else {
        [self loginSuccessWithUserModel:user];
    }
    //end
}

/**
 *  初始化界面的跟试图部分
 */
- (void)myInitController
{
    MMTabbarController *tabbarController = [[MMTabbarController alloc] init];
    //避免聊天和去答的scrollview滑动出问题
    tabbarController.automaticallyAdjustsScrollViewInsets = NO;
    //初始化四个标签页
    self.tabbarVC = tabbarController;
    
    NSArray *vcTmp = @[@"DKHomeViewController",@"DKCaringViewController",@"DKCompositeIndexViewController",@"DKUserViewController"];
    NSArray *tmpImgArray = nil;
    NSArray *tmpTitleArray = nil;
    tmpImgArray = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"tabbar1_nor"],
                   [UIImage imageNamed:@"tabbar2_nor"],
                   [UIImage imageNamed:@"tabbar3_nor"],
                   [UIImage imageNamed:@"tabbar4_nor"], nil];
    tmpTitleArray = @[@"数据",@"关怀",@"综合",@"账户"];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSInteger index = 0; index < [vcTmp count]; index ++) {
        UIViewController *vcViewTmp = [[NSClassFromString(vcTmp[index]) alloc] init];
        
        [vcViewTmp.tabBarItem setImage:[tmpImgArray objectAtIndex:index]];
        [vcViewTmp.tabBarItem setTitle:tmpTitleArray[index]];
        [vcViewTmp.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -1)];
        [vcViewTmp.tabBarItem setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          MMRGBColor(53, 54, 55), NSForegroundColorAttributeName,
          nil] forState:UIControlStateNormal];
        [vcViewTmp.tabBarItem setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          DKTabbarColor, NSForegroundColorAttributeName,
          nil] forState:UIControlStateSelected];
        [tmpArray addObject:vcViewTmp];
    }
    
    [tabbarController.tabBar setBarStyle:UIBarStyleDefault];
    tabbarController.tabBar.translucent = YES;
    tabbarController.delegate = self;
    
    //end
    [[UITabBar appearance] setTintColor:DKTabbarColor];
    [tabbarController setViewControllers:tmpArray];
    
    //初始化导航栏
    MLNavigationController *navTmp = [[MLNavigationController alloc] initWithRootViewController:tabbarController];
    navTmp.navigationBarHidden = YES;
    self.window.rootViewController = navTmp;
}

- (MLNavigationController *)rootNav
{
    return (MLNavigationController *)self.window.rootViewController;
}

/**
 *  返回当前的nav
 *
 *  @return 当前的nav
 */
- (MLNavigationController *)nav
{
    MLNavigationController *nav = (MLNavigationController *)self.window.rootViewController;
    if (nav.presentedViewController) {
        UIViewController *presentedVC = nav.presentedViewController;
        if (presentedVC.presentedViewController) {
            presentedVC = presentedVC.presentedViewController;
        }
        if ([presentedVC isKindOfClass:[MLNavigationController class]]) {
            return (MLNavigationController *)presentedVC;
        }
    }
    return nav;
}

- (void)presentLoginVCWithAnimated:(BOOL)flag
{
    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:[NSClassFromString(@"DKLoginViewController") new]];
    [MMAppDelegate.rootNav presentViewController:nav animated:flag completion:NULL];
}

/**
 *  登录成功后调用
 */
- (void)loginSuccessWithUserModel:(DKUser *)userModel
{
    DKUser *user = userModel?:[[MMAppDelegateHelper shareHelper] currentUser];
    [DKSocketRequestHelper Helper].secssionId = user.userId;
    //判断是否绑定了设备，如果没绑定，则跳转到绑定界面
    if (user.terminals == nil || [user.terminals count] == 0) {
        UIViewController *vc = [NSClassFromString(@"DKAccountSwitchViewController") new];
        vc.view.hidden = YES;
        [MMAppDelegate.nav pushViewController:vc animated:NO];
        MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:[NSClassFromString(@"DKSettingDeviceViewController") new]];
        [MMAppDelegate.nav presentViewController:nav animated:NO completion:^{
            vc.view.hidden = NO;
        }];
    }
    //end
    //判断是否已有当前选择的设置，如果没有，则跳转到设备选择界面
    else if (user.selectedSerialNumber == nil || [user.selectedSerialNumber length] == 0)
    {
        [MMAppDelegate.nav pushViewController:[NSClassFromString(@"DKAccountSwitchViewController") new] animated:NO];
    }
}

#pragma mark - MMPushManagerDelegate

/**
 *  显示 alertview
 *
 *  @param pushInfo 推送消息对象
 */
- (void)pushManagerReceiveMessageWithInfo:(YAPushInfoObject *)pushInfo
{
    if (pushInfo == nil || [pushInfo isKindOfClass:[YAPushInfoObject class]] == NO) {
        return;
    }
    //说明是同一次任务 多次推送了
    if (previousPushInfo && [previousPushInfo.pushId integerValue] == [pushInfo.pushId integerValue]) {
        return;
    }
    //end
    previousPushInfo = pushInfo;
    [self disposePushMessageWithInfo:pushInfo];
}

/**
 *  处理推送的消息
 *
 *  @param pushInfo 推送内容
 */
- (void)disposePushMessageWithInfo:(YAPushInfoObject *)pushInfo
{
    
#pragma mark 推送预处理判断
    //判断要不要处理
    if ([pushInfo.pushType integerValue] == 0) {
        return;
    }
    //end
    //判断是不是在别的地方登录
    if ([pushInfo.pushType integerValue] == 5) {
        [[MMAppDelegateHelper shareHelper] userLoginOut:YES];
        //用户登录界面
        //[UIViewController triggerRoute:OPEN_USERLOGIN_PAGE withParameters:nil];
        return;
    }
    //end
    //转账失败推送时，判断当前登录用户是不是推送返回的用户
    if ([pushInfo.pushType integerValue] == 9) {
        NSString *currentUserId = [[MMAppDelegateHelper shareHelper] currentUserId];
        if (currentUserId == nil || [currentUserId integerValue] != [pushInfo.userId integerValue]) {
            return;
        }
    }
    //end
    
#if DEBUG
    NSLog(@"MMPushManager---pushManagerReceiveMessageWithInfo---");
#endif
    
#pragma mark 推送正式处理
    if (pushInfo.displayAlertView) {
        //如果是认证结果
        if ([pushInfo.pushType integerValue] == 6 || [pushInfo.pushType integerValue] == 7) {

            //end
            MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:@"通知" message:pushInfo.pushTitle delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了",nil];
            alertManage.alertData = pushInfo;
            [alertManage show];
            return;
        }
        //end
        MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:@"通知" message:pushInfo.pushTitle delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
        alertManage.alertData = pushInfo;
        [alertManage show];
        return;
    }
    //对推送结果做处理
    switch ([pushInfo.pushType integerValue]) {

        default:
            break;
    }
    //end
}

#pragma mark - MMAlertManageDelegate

- (void)alertView:(MMAlertManage *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    YAPushInfoObject *pushInfo = alertView.alertData;
    pushInfo.displayAlertView = NO;
    [self disposePushMessageWithInfo:pushInfo];
}

#pragma mark - Status bar touch tracking 添加状态栏点击通知

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [self statusBarTouchedAction];
    }
}

- (void)statusBarTouchedAction {
    
    //判断是否能直接移动
    UIViewController *visibleViewController = [MMAppDelegate.nav visibleViewController];
    
    [[[visibleViewController view] subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)obj setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        if ([obj isKindOfClass:NSClassFromString(@"ScrollViewVC")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([obj respondsToSelector:@selector(statusBarTappedAction)])
            {
                [obj performSelector:@selector(statusBarTappedAction)];
            }
#pragma clang diagnostic pop
            
        }
    }];
    //end
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification object:nil];
}

#pragma mark - getters and setters

- (MMAppDelegateModel *)appModel
{
    if (_appModel == nil) {
        _appModel = [[MMAppDelegateModel alloc] init];
    }
    return _appModel;
}

- (MMPushManager *)pushManager
{
    if (_pushManager == nil) {
        _pushManager = [[MMPushManager alloc] init];
        _pushManager.c_delegate = self;
        //[[NSNotificationCenter defaultCenter] addObserver:_pushManager selector:@selector(loginCheckDoneNotification) name:kLoginCheckDoneNotification object:nil];
    }
    return _pushManager;
}

- (MMCheckAppUpdateHelper *)updateHelper
{
    if (_updateHelper == nil) {
        _updateHelper = [MMCheckAppUpdateHelper new];
    }
    return _updateHelper;
}

- (BOOL)isInstallWeiXin
{
    return [WXApi isWXAppInstalled];
}

- (BOOL)isInstallQQ
{
    return [QQApiInterface isQQInstalled];
}

- (BOOL)isShowShare
{
    return [self isInstallWeiXin] || [self isInstallQQ];
}

//- (MMLocationHelper *)locationHelper
//{
//    if (_locationHelper == nil) {
//        _locationHelper = [MMLocationHelper new];
//    }
//    return _locationHelper;
//}

@end
