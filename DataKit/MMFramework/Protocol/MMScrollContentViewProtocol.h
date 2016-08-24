//
//  MMScrollContentViewProtocol.h
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMScrollContentViewProtocol <NSObject>

/**
 *  背部滑动试图
 */
@property (weak, nonatomic) UIScrollView *ui_scrollView;

/**
 *  内容试图
 */
@property (weak, nonatomic) UIView *ui_contentView;

/**
 *  内容试图高度
 */
@property (weak, nonatomic) NSLayoutConstraint *ui_contentViewHeightConstraint;

@end
