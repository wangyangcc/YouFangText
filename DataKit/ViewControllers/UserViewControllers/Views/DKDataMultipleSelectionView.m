//
//  DKDataMultipleSelectionView.m
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDataMultipleSelectionView.h"

@implementation DKDataMultipleSelectionView
{
    UIView *contentView; /**< 内容试图 */
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        contentView = [UIView new];
        contentView.backgroundColor = MMRGBColor(235, 235, 235);
        [self addSubview:contentView];
        contentView.frame = CGRectMake(0, -kDataMultipleSelectionContentHeight, kDataMultipleSelectionContentWidth, kDataMultipleSelectionContentHeight);

        NSArray *selectionArray = @[@"低", @"偏低", @"正常", @"偏高", @"高"];
        for (NSInteger index = 0; index < [selectionArray count]; index ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:selectionArray[index] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitleColor:MMRGBColor(30, 30, 30) forState:UIControlStateNormal];
            //[button setBackgroundColor:MMRGBColor(252, 252, 252)];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [contentView addSubview:button];
            [button autoSetDimension:ALDimensionHeight toSize:38];
            [button autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
            [button autoPinEdgeToSuperviewEdge:ALEdgeLeading];
            [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:38*index];
            button.tag = 100 + index;
            [button addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
            
            //分割线
            if (index < [selectionArray count] - 1) {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = MMRGBColor(183, 183, 183);
                [contentView addSubview:line];
                [line autoSetDimension:ALDimensionHeight toSize:0.5];
                [line autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
                [line autoPinEdgeToSuperviewEdge:ALEdgeLeading];
                [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:button];
            }
            //end
        }
    }
    return self;
}

- (void)buttonTaped:(UIButton *)button
{
    if (self.onButtonTouchUpInside) {
        self.onButtonTouchUpInside(self,[button titleForState:UIControlStateNormal]);
    }
}

- (BOOL)isShow
{
    return (int)CGRectGetMinY(contentView.frame) == 0;
}

- (BOOL)show
{
    if ((int)CGRectGetMinY(contentView.frame) == 0) {
        return NO;
    }
    [UIView animateWithDuration:0.35 animations:^{
        contentView.frame = CGRectMake(0, 0, kDataMultipleSelectionContentWidth, kDataMultipleSelectionContentHeight);
    }];
    return YES;
}

- (BOOL)hideWithCompletion:(void (^)(BOOL finished))completion
{
    if ((int)CGRectGetMinY(contentView.frame) == -kDataMultipleSelectionContentHeight) {
        return NO;
    }
    [UIView animateWithDuration:0.35 animations:^{
        contentView.frame = CGRectMake(0, -kDataMultipleSelectionContentHeight, kDataMultipleSelectionContentWidth, kDataMultipleSelectionContentHeight);
    } completion:completion];
    return YES;
}

@end
