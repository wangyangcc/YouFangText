//
//  MMSideslipScrollview.m
//  Datakit
//
//  Created by wangyangyang on 15/6/24.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMSideslipScrollview.h"

#define SS_ViewWidth [[UIScreen mainScreen] bounds].size.width

@implementation MMSideslipScrollview

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //判断 是否是已经移动到了边缘 判断 是否启动侧边栏
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self].x;
        CGFloat contentOffX = self.contentOffset.x;
        CGFloat contentSizeWidth = self.contentSize.width;
        if (contentOffX == 0 && velocityX >= 0) {
            self.bounces = NO;
            return YES;
        }
        else if (contentOffX == contentSizeWidth - SS_ViewWidth && velocityX <= 0) {
            self.bounces = NO;
            return YES;
        }
    }
    self.bounces = YES;
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        //判断 是否是已经移动到了边缘 如果是则 此事件交给 FYSideBarVC 处理 启动侧边栏
        CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self].x;
        CGFloat contentOffX = self.contentOffset.x;
        CGFloat contentSizeWidth = self.contentSize.width;
        if ([self isDragging] == NO && contentOffX == 0 && velocityX >= 0) {
            return YES;
        }
        else if ([self isDragging] == NO && contentOffX >= contentSizeWidth - SS_ViewWidth && velocityX <= 0) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addSubview:(UIView *)view
{
    if ([view isKindOfClass:[UIImageView class]]) {
        return;
    }
    [super addSubview:view];
}

@end
