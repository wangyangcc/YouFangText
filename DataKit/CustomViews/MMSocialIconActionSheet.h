//
//  MMSocialIconActionSheet.h
//  XinHuaInternation
//
//  Created by wangyangyang on 15/1/25.
//  Copyright (c) 2015年 Xin Hua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMSocialIconActionSheet : UIView <UIScrollViewDelegate>
{
    UIScrollView *_actionSheetBackground;
    UIImageView * _backgroundImageView;
    UIButton *_cancelButton;
    NSArray *_snsNames;
    
    NSString *m_shareText;
    id m_shareImage;
}

/**
 平台数组
 
 */
@property (nonatomic, retain, readonly) NSArray *snsNames;

@property (nonatomic, weak, readonly) id  socialUIDelegate;

/**
 初始化方法
 
 @param snsNames 每小格对应的sns平台名，在`UMSocialEnum.h`定义
 @param authorization 处理点击之后的block处理对象
 @param delegate 回调代理
 */
- (id)initWithItems:(NSArray *)items
           delegate:(id)delegate
          shareText:(NSString *)shareText
         shareImage:(id)shareImage;

/**
 讲自己自下往上弹出来
 */
-(void)show;
/**
 将自己移除
 
 */
-(void)dismiss;

@end
