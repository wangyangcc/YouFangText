//
//  UIViewController+tapCanceGesture.m
//  Datakit
//
//  Created by wangyangyang on 15/5/28.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "UIViewController+tapCanceGesture.h"
#import <objc/runtime.h>

static char tapCanceBlockKey;

@implementation UIViewController (tapCanceGesture)
@dynamic tapCanceBlock;

- (void)addTapCanceGestureWithBlock:(void(^)())block
{
    self.tapCanceBlock = block;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTouchUpInside)];
    [self.view addGestureRecognizer:tapGes];
}

- (void)removeTapCanceGesture
{
    if (self.tapCanceBlock != NULL) {
        self.tapCanceBlock = NULL;
        [[self.view gestureRecognizers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UITapGestureRecognizer class]]) {
                [self.view removeGestureRecognizer:(UITapGestureRecognizer *)obj];
                *stop = YES;
            }
        }];
    }
}

- (void)setTapCanceBlock:(void (^)(void))tapCanceBlock
{
    objc_setAssociatedObject (self, &tapCanceBlockKey,tapCanceBlock,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(void))tapCanceBlock
{
    return objc_getAssociatedObject(self, &tapCanceBlockKey);
}

- (void)doTouchUpInside
{
    self.tapCanceBlock();
}

@end
