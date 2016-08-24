//
//  DKCompositeIndexView.h
//  DataKit
//
//  Created by wangyangyang on 15/12/2.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTotalValue 100

@interface DKCompositeIndexView : UIView

- (instancetype)initWithFrame:(CGRect)frame isLeft:(BOOL)isLeft;

/**
 *  更新试图
 *
 *  @param bigNumber   大圈数字
 *  @param smallNumber 小圈数字
 */
- (void)updateViewWithBigNumber:(NSString *)bigNumber
                    smallNumber:(NSString *)smallNumber
                     signString:(NSString *)signString
                         isLeft:(BOOL)isLeft;

@end
