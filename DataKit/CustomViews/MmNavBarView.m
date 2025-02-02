//
//  CustomeNavBarView.m
//  QiongHai
//
//  Created by Tiank on 14-3-20.
//  Copyright (c) 2014年 xhmm. All rights reserved.
//

#import "MmNavBarView.h"
#define UITextAlignmentCenter NSTextAlignmentCenter

@implementation MmNavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        //自定义导航栏背景View
        self.m_navBackgroundImage = [[UIImageView alloc] init];
        self.m_navBackgroundImage.backgroundColor = DKNavbackcolor;
        self.m_navBackgroundImage.frame = self.bounds;
        //end
        
        //自定义导航栏的标题
        self.m_navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, [self height] - 44, ScreenWidth - 110, 44)];
        self.m_navTitleLabel.textAlignment = UITextAlignmentCenter;
        self.m_navTitleLabel.font = [UIFont systemFontOfSize:20];
        self.m_navTitleLabel.textColor = [UIColor whiteColor];
        self.m_navTitleLabel.backgroundColor = [UIColor clearColor];
        //end
        
        //自定义导航栏的leftButton和rightBtn
        self.m_navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.m_navLeftBtn.frame = CGRectMake(0, [self height] - 44, 55, 44);
        //self.m_navLeftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.m_navLeftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.m_navLeftBtn setTintColor:[UIColor whiteColor]];
        [self.m_navLeftBtn addTarget:self action:@selector(leftBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.m_navLeftBtn setBackgroundImage:self.m_navLeftBtnImage forState:UIControlStateNormal];
        
        self.m_navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.m_navRightBtn.frame = CGRectMake(ScreenWidth - 55, [self height] - 44, 55, 44);
        self.m_navRightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        self.m_navRightBtn.backgroundColor = [UIColor clearColor];
        [self.m_navRightBtn addTarget:self action:@selector(rightBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        //end
        
        [self addSubview:self.m_navBackgroundImage];
        [self addSubview:self.m_navLeftBtn];
        [self addSubview:self.m_navRightBtn];
        [self addSubview:self.m_navTitleLabel];
        
    }
    return self;
}

#pragma mark-
#pragma mark 设置自定义导航条颜色
//设置自定义导航栏的颜色风格
- (void)setM_navColorStyle:(MmNavBarViewColorStyle)aStyle
{
    if (aStyle == MmNavBarViewColorStyleWhite) {
        _m_navColorStyle = MmNavBarViewColorStyleWhite;
        self.backgroundColor = [UIColor whiteColor];
        [self.m_navLeftBtn setImage:self.m_navLeftBtnImage forState:UIControlStateNormal];
        self.m_navTitleLabel.textColor = [UIColor blackColor];
        
    }
    else if (aStyle == MmNavBarViewColorStyleDefault)
    {
        _m_navColorStyle = MmNavBarViewColorStyleDefault;
        self.backgroundColor = [UIColor colorWithRed:124/255.0 green:188/255.0 blue:77/255.0 alpha:1];
        [self.m_navLeftBtn setImage:self.m_navLeftBtnImage forState:UIControlStateNormal];
        self.m_navTitleLabel.textColor = [UIColor whiteColor];
        
    }else if (aStyle == MmNavBarViewColorStyleTransparent)
    {
        _m_navColorStyle = MmNavBarViewColorStyleTransparent;
        self.m_navBackgroundImage = nil;
        self.backgroundColor = [UIColor clearColor];
        self.m_navTitleLabel.textColor = [UIColor whiteColor];
        
    }else if (aStyle == MmNavBarViewColorStyleBlue)
    {
        _m_navColorStyle = MmNavBarViewColorStyleBlue;
       self.backgroundColor = [UIColor colorWithRed:124/255.0 green:188/255.0 blue:77/255.0 alpha:1];
        self.m_navTitleLabel.textColor = [UIColor whiteColor];
        
    }
}
//end

//导航条左右按钮点击事件
- (void)leftBtnTapped
{
    if ([self.m_navBarDelegate respondsToSelector:@selector(navLeftBtnTapped)]) {
        [self.m_navBarDelegate navLeftBtnTapped];
    }
}

- (void)rightBtnTapped
{
    if ([self.m_navBarDelegate respondsToSelector:@selector(navRightBtnTapped)]) {
        [self.m_navBarDelegate navRightBtnTapped];
    }
}

//end

//导航条左右按钮图片设置
- (void)setM_navLeftBtnImage:(UIImage *)m_navLeftBtnImage
{
    if (m_navLeftBtnImage == nil) {
        self.m_navLeftBtn.frame = CGRectMake(0, [self height] - 44, 55, 44);
    }
    else {
        self.m_navLeftBtn.frame = CGRectMake(0, [self height] - 44, 44, 44);
    }
    [self.m_navLeftBtn setImage:m_navLeftBtnImage forState:UIControlStateNormal];
}

- (void)setM_navRightBtnImage:(UIImage *)m_navRightBtnImage
{
    if (m_navRightBtnImage == nil) {
        self.m_navLeftBtn.frame = CGRectMake(0, [self height] - 44, 55, 44);
    }
    else {
        self.m_navLeftBtn.frame = CGRectMake(0, [self height] - 44, 44, 44);
    }
    [self.m_navRightBtn setImage:m_navRightBtnImage forState:UIControlStateNormal];
}
//end

@end
