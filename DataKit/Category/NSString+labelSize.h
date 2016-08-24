//
//  NSString+labelSize.h
//  Datakit
//
//  Created by wangyangyang on 15/6/27.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (labelSize)

/**
 *  通用的获取labelsie的方法
 *
 *  @param text      内容
 *  @param labelSize      label大小
 *  @param font      字体
 *  @param textColor 颜色
 *
 *  @return 大小
 */
+ (CGSize)generalLabelSizeWithText:(NSString *)text
                         labelSize:(CGSize)labelSize
                              font:(UIFont *)font
                         textColor:(UIColor *)textColor;

/**
 *  通用的获取labelsie的方法
 *
 *  @param attributedString 属性字符串
 *  @param labelSize      label大小
 *
 *  @return 大小
 */
+ (CGSize)generalLabelSizeWithAttributedString:(NSAttributedString *)attributedString
                                     labelSize:(CGSize)labelSize;

/**
 *  通用的获取labelsie的方法
 *
 *  @param text      内容
 *  @param labelSize      label大小
 *  @param font      字体
 *  @param lineSpacing 行间距
 *
 *  @return 大小
 */

+ (CGSize)generalLabelSizeWithText:(NSString *)text
                         labelSize:(CGSize)labelSize
                              font:(UIFont *)font
                       lineSpacing:(CGFloat)lineSpacing;
@end
