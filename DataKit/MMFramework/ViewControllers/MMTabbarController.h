//
//  MMTabbarController.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/4.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTabbarController : UITabBarController


@end

@interface UIViewController (mmTabbar)

- (MMTabbarController *)m_tabbarVC;

@end
