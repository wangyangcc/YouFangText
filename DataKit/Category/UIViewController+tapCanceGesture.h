//
//  UIViewController+tapCanceGesture.h
//  Datakit
//
//  Created by wangyangyang on 15/5/28.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Block.h"

@interface UIViewController (tapCanceGesture)

@property (nonatomic, copy) void (^tapCanceBlock)(void);

- (void)addTapCanceGestureWithBlock:(void(^)())block;

- (void)removeTapCanceGesture;

@end
