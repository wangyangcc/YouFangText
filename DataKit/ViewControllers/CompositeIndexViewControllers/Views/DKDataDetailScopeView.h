//
//  DKDataDetailScopeView.h
//  DataKit
//
//  Created by wangyangyang on 15/12/8.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDKDataDetailScopeViewContentWidth 120
#define kDKDataDetailScopeViewContentHeight 71

@interface DKDataDetailScopeView : UIView

@property (nonatomic, copy) NSString *tagSelection;

@property (copy) void (^onButtonTouchUpInside)(DKDataDetailScopeView *selectionView, NSInteger buttonIndex, NSString *buttonString);

/**
 *  是否在动画中
 */
@property (nonatomic, assign) BOOL isAnimation;

- (BOOL)isShow;

- (BOOL)show;

- (BOOL)hideWithCompletion:(void (^)(BOOL finished))completion;

@end
