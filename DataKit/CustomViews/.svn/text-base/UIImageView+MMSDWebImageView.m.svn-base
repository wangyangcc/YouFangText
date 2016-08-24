//
//  UIImageView+MMSDWebImageView.m
//  XinHuaInternation
//
//  Created by wangyangyang on 15/1/20.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "UIImageView+MMSDWebImageView.h"
#import "NetWorkObserver.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (MMSDWebImageView)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
//    if ([XinHuaAppDelegate.appModel noWifiHavePhoto] == YES && [NetWorkObserver isSetImageViewVisible] == NO) {
//        url = nil;
//    }
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageLowPriority progress:nil completed:nil];
}

/**
 *  请求网络图片，总是显示
 *
 *  @param url         url
 *  @param placeholder 默认图
 */
- (void)setImageAlwayDisplayWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageLowPriority progress:nil completed:nil];
}

@end
