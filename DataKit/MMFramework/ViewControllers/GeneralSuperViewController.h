//
//  CustomeSuperViewController.h
//  QiongHai
//
//  Created by Tiank on 14-2-23.
//  Copyright (c) 2014年 xhmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "MmNavBarView.h"
#import "DKClientRequest.h"

@interface GeneralSuperViewController : SuperViewController<UIScrollViewDelegate,MmNavBarViewDelegate, DKClientRequestCallBackDelegate>

@property (strong, nonatomic) MmNavBarView   *customeNavBarView;

/**
 *  在控制器释放掉的时候，隐藏ProgressHUD 默认为 YES
 */
@property (nonatomic, assign) BOOL dismmProgressHUDWhenDealloc;

- (void)navLeftBtnTapped;
- (void)navRightBtnTapped;

/**
 *   @brief 显示无网络时提示
 **/
- (void)showNetworkErrorWithCallBack:(SEL)callBack;

/**
 *   @brief 根据文字显示默认的提示界面
 **/
- (void)showDefaultPromptWithText:(NSString *)defaultText;

/**
 *  显示提示界面
 *
 *  @param defaultText 内容
 *  @param iconImage   icon
 */
- (UIView *)showPromptTextWithText:(NSString *)defaultText
                         iconImage:(NSString *)iconImage;

/**
 *   @brief 隐藏默认提示文字
 **/
- (void)hideDefaultText;

/**
 *  设置是否接受响应，除了导航条
 *
 *  @param enabled bool值
 */
- (void)setUserInteractionEnabled:(BOOL)enabled;

@end

@interface YANetworkErrorButton : UIButton

@end
