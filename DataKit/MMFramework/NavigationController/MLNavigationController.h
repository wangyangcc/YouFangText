//
//  MLNavigationController.h
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef __IPHONE_7_0
typedef NS_OPTIONS(NSUInteger, UIRectEdge) { //  让 xocde4 能编译过
    UIRectEdgeNone   = 0,
    UIRectEdgeTop    = 1 << 0,
    UIRectEdgeLeft   = 1 << 1,
    UIRectEdgeBottom = 1 << 2,
    UIRectEdgeRight  = 1 << 3,
    UIRectEdgeAll    = UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight
};
#endif

@protocol MLNavigationControllerDelegate <NSObject>

- (UIViewController *) pushCommentViewController;

@end

@interface MLNavigationController : UINavigationController <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (weak) id<MLNavigationControllerDelegate> m_delegate;

//外部控制滑动
@property (nonatomic) BOOL isSlider;

- (void) pushViewController:(UIViewController *)viewController;
- (void) popViewController;
- (void) popViewControllerToRoot;
- (void) popToViewController:(NSString *) viewControlString;
- (void) popToDownViewController:(NSString *) viewControlString;

@end

@interface UIViewController (mlNav)

- (MLNavigationController *)m_nav;

@end
