//
//  UIButton+MMSDButtom.m
//  XinHuaInternation
//
//  Created by wangyangyang on 15/1/20.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "UIButton+MMSDButtom.h"
#import "UIButton+WebCache.h"
#import "NetWorkObserver.h"

@implementation UIButton (MMSDButtom)

/**
 *  请求网络图片，会根据无图模式判断
 *
 *  @param url         url地址
 *  @param placeholder 默认图
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
//    if ([XinHuaAppDelegate.appModel noWifiHavePhoto] == YES && [NetWorkObserver isSetImageViewVisible] == NO) {
//        url = nil;
//    }
    [self sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:placeholder options:SDWebImageLowPriority completed:nil];
}

/**
 *  请求网络图片，总是显示
 *
 *  @param url         url
 *  @param placeholder 默认图
 */
- (void)setImageAlwayDisplayWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:placeholder options:SDWebImageLowPriority completed:nil];
}

/**
 *  请求网络图片，会根据无图模式判断
 *
 *  @param url         url地址
 *  @param placeholder 默认图
 */
- (void) setBackgroundImageWithUrl:(NSURL *)url forState:(UIControlState)controlState placeholderImgae:(UIImage *)placehoulder
{
//    if ([XinHuaAppDelegate.appModel noWifiHavePhoto] == YES && [NetWorkObserver isSetImageViewVisible] == NO) {
//        url = nil;
//    }
//    
    [self sd_setBackgroundImageWithURL:url forState:controlState placeholderImage:placehoulder];
}

/**
 *  请求网络图片，总是显示
 *
 *  @param url         url
 *  @param placeholder 默认图
 */
- (void) setBackgroundImageAlwayDisplayWithUrl:(NSURL *)url forState:(UIControlState)controlState placeholderImgae:(UIImage *)placehoulder
{
    [self sd_setBackgroundImageWithURL:url forState:controlState placeholderImage:placehoulder];
}
@end
