//
//  NSString+labelSize.m
//  Datakit
//
//  Created by wangyangyang on 15/6/27.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "NSString+labelSize.h"

@implementation NSString (labelSize)

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
                         textColor:(UIColor *)textColor
{
    if (text == nil || font == nil || textColor == nil) {
        return CGSizeZero;
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange allRange = NSMakeRange(0, text.length);
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:allRange];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:textColor
                    range:allRange];
    CGRect titleLabelRect = [attrStr boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return CGSizeMake(titleLabelRect.size.width, titleLabelRect.size.height + 2);
}

/**
 *  通用的获取labelsie的方法
 *
 *  @param attributedString 属性字符串
 *
 *  @return 大小
 */
+ (CGSize)generalLabelSizeWithAttributedString:(NSAttributedString *)attributedString
                                     labelSize:(CGSize)labelSize
{
    if (attributedString == nil) {
        return CGSizeZero;
    }
    CGRect titleLabelRect = [attributedString boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return CGSizeMake(titleLabelRect.size.width, titleLabelRect.size.height + 2);
}

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
                       lineSpacing:(CGFloat)lineSpacing
{
    if (text == nil || font == nil) {
        return CGSizeZero;
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange allRange = NSMakeRange(0, text.length);
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:allRange];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor blackColor]
                    range:allRange];
    
    //加入行间距
    if (lineSpacing > 0.0000001) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = lineSpacing;
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:paragraphStyle
                        range:allRange];
    }
    //end
    
    CGRect titleLabelRect = [attrStr boundingRectWithSize:labelSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    return CGSizeMake(titleLabelRect.size.width, titleLabelRect.size.height + 2);
}

@end
