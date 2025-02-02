//
//  CustomeNavBarView.h
//  QiongHai
//
//  Created by Tiank on 14-3-20.
//  Copyright (c) 2014年 xhmm. All rights reserved.
//

typedef NS_ENUM(int, MmNavBarViewColorStyle){
    
    MmNavBarViewColorStyleDefault = 0, //默认颜色
    MmNavBarViewColorStyleWhite, //白色
    MmNavBarViewColorStyleTransparent,//透明
    MmNavBarViewColorStyleBlue,//蓝色
    
};


#import <UIKit/UIKit.h>

//左右按钮点击事件代理声明
@protocol MmNavBarViewDelegate <NSObject>

- (void) navLeftBtnTapped;
- (void) navRightBtnTapped;

@end

//自身属性声明
@interface MmNavBarView : UIView

@property (weak, nonatomic) id<MmNavBarViewDelegate> m_navBarDelegate;
@property (strong, nonatomic) UIButton *m_navLeftBtn;
@property (strong, nonatomic) UIButton *m_navRightBtn;
@property (strong, nonatomic) UIImage  *m_navLeftBtnImage;
@property (strong, nonatomic) UIImage  *m_navRightBtnImage;
@property (strong, nonatomic) UILabel  *m_navTitleLabel;
@property (strong, nonatomic) UIImageView  *m_navBackgroundImage;
@property (assign, nonatomic) MmNavBarViewColorStyle m_navColorStyle;

@end

