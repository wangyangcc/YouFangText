//
//  UIImage+screenshot.m
//  DataKit
//
//  Created by wangyangyang on 15/12/4.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "UIImage+screenshot.h"

@implementation UIImage (screenshot)

+ (nullable UIImage *)screenshotForView:(nullable UIView *)view
{
    if (view == nil) {
        return nil;
    }
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height - 20), NO, 0.0f);
    }
    //获取图像
    //[view.layer renderInContext:UIGraphicsGetCurrentContext()];
    [view drawViewHierarchyInRect:CGRectMake(0, -20, ScreenWidth, CGRectGetHeight(view.bounds)) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //end
    
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
//    
//    [view drawHierarchyInRect:view.bounds afterScreenUpdates:YES];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

@end
