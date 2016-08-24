//
//  MMTabbarController.m
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/4.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMTabbarController.h"

@interface MMTabbarController () <UITabBarControllerDelegate>

@end

@implementation MMTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 设置状态栏类型
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.selectedViewController preferredStatusBarStyle];
}

#pragma mark - 屏幕旋转设置 相关

/**
 *   @brief 添加方法 取消旋转
 *
 **/
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

@end

@implementation UIViewController (mmTabbar)

- (MMTabbarController *)m_tabbarVC
{
    return nil;
}

@end