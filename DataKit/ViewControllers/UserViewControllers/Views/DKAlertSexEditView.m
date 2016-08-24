//
//  DKAlertSexEditView.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKAlertSexEditView.h"

@implementation DKAlertSexEditView
{
    UIImageView *sexSignView;
    UIView *sexButtonView;
    
    NSInteger selectedIndex;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        [self myInit];
    }
    return self;
}

#pragma mark custom method

- (void)myInit
{
    //性别标示
    sexSignView = [UIImageView new];
    sexSignView.image = [UIImage imageNamed:@"sex-man"];
    [self addSubview:sexSignView];
    [sexSignView autoSetDimensionsToSize:CGSizeMake(75, 75)];
    [sexSignView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [sexSignView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:23];
    UIView *sexSignViewCon = [UIView new];
    sexSignViewCon.layer.masksToBounds = YES;
    sexSignViewCon.layer.cornerRadius = 42; //圆角
    sexSignViewCon.layer.borderWidth = 1.0;//边框
    [self addSubview:sexSignViewCon];
    [sexSignViewCon autoSetDimensionsToSize:CGSizeMake(85, 85)];
    [sexSignViewCon autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [sexSignViewCon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:21];
    //提示文字
    UILabel *label = [UILabel new];
    label.text = @"选择手表使用者的性别";
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17];
    [self addSubview:label];
    [label autoSetDimension:ALDimensionHeight toSize:21];
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [label autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
    [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:sexSignView withOffset:23];
    //end
    
    //性别选择按钮
    selectedIndex = 0;
    sexButtonView = [UIView new];
    [self addSubview:sexButtonView];
    [sexButtonView autoSetDimensionsToSize:CGSizeMake(40 + 60*2, 60)];
    [sexButtonView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [sexButtonView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:label withOffset:23];
    
    UIButton *buttonSex = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSex setBackgroundImage:[UIImage imageNamed:@"man-1"] forState:UIControlStateNormal];
    [buttonSex setBackgroundImage:[UIImage imageNamed:@"man-2"] forState:UIControlStateSelected];
    [buttonSex addTarget:self action:@selector(personTaped:) forControlEvents:UIControlEventTouchUpInside];
    buttonSex.selected = YES;
    buttonSex.tag = 100;
    [sexButtonView addSubview:buttonSex];
    [buttonSex autoSetDimensionsToSize:CGSizeMake(60, 60)];
    [buttonSex autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [buttonSex autoPinEdgeToSuperviewEdge:ALEdgeTop];
    
    buttonSex = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSex setBackgroundImage:[UIImage imageNamed:@"woman-1"] forState:UIControlStateNormal];
    [buttonSex setBackgroundImage:[UIImage imageNamed:@"woman-2"] forState:UIControlStateSelected];
    [buttonSex addTarget:self action:@selector(personTaped:) forControlEvents:UIControlEventTouchUpInside];
    buttonSex.tag = 200;
    [sexButtonView addSubview:buttonSex];
    [buttonSex autoSetDimensionsToSize:CGSizeMake(60, 60)];
    [buttonSex autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [buttonSex autoPinEdgeToSuperviewEdge:ALEdgeTop];
    //end
    
    //确认按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"sexSelectDone"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneButton setTitle:@"确定后不能修改哦!" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneButton];
    [doneButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:45];
    [doneButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:45];
    [doneButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:23];
    [doneButton autoSetDimension:ALDimensionHeight toSize:45];
    //end
}

- (void)setDefaultSelectIndex:(NSInteger)defaultSelectIndex
{
    if (defaultSelectIndex == 1) {
        [self personTaped:[sexButtonView viewWithTag:200]];
    }
}

- (void)personTaped:(UIButton *)button
{
    if ([button isSelected]) {
        return;
    }
    if (button.tag == 100) {
        selectedIndex = 0;
        sexSignView.image = [UIImage imageNamed:@"sex-man"];
        [(UIButton *)[sexButtonView viewWithTag:200] setSelected:NO];
    }
    else {
        selectedIndex = 1;
        sexSignView.image = [UIImage imageNamed:@"sex-woman"];
        [(UIButton *)[sexButtonView viewWithTag:100] setSelected:NO];
    }
    button.selected = YES;
}

- (void)doneButtonTaped:(UIButton *)button
{
    if (self.onButtonTouchUpInside) {
        self.onButtonTouchUpInside(self,selectedIndex);
    }
}

@end
