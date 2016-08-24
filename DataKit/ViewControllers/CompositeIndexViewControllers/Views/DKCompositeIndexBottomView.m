//
//  DKCompositeIndexBottomView.m
//  DataKit
//
//  Created by wangyangyang on 15/12/2.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCompositeIndexBottomView.h"
#import "DKCompositeIndexBottomData.h"

@implementation DKCompositeIndexBottomView
{
    UIImageView *_backView;
    
    UILabel *_leftLabel;
    UILabel *_middleLabel;
    UILabel *_rightLabel;
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UIImageView *backView = [UIImageView new];
        backView.image = [UIImage imageNamed:@"indexBl"];
        [self addSubview:backView];
        _backView = backView;
        [backView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        
        //布局相关
        CGFloat leftSpace = 24*ScreenWidth/375;
        CGFloat leftRightLabelWid = ((width - leftSpace*2)/5)*2;
        CGFloat middleLableWid = ((width - leftSpace*2)/5);
        
        UILabel *leftLabel = [UILabel new];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.numberOfLines = 2;
        [self addSubview:leftLabel];
        [leftLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:leftSpace];
        [leftLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [leftLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [leftLabel autoSetDimension:ALDimensionWidth toSize:leftRightLabelWid];
        _leftLabel = leftLabel;
        
        UILabel *middleLabel = [UILabel new];
        middleLabel.textAlignment = NSTextAlignmentCenter;
        middleLabel.numberOfLines = 2;
        [self addSubview:middleLabel];
        [middleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [middleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [middleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [middleLabel autoSetDimension:ALDimensionWidth toSize:middleLableWid];
        _middleLabel = middleLabel;
        
        UILabel *rightLabel = [UILabel new];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        rightLabel.numberOfLines = 2;
        [self addSubview:rightLabel];
        [rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:leftSpace];
        [rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [rightLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [rightLabel autoSetDimension:ALDimensionWidth toSize:leftRightLabelWid];
        _rightLabel = rightLabel;
        
        middleLabel.text = @"加载中...";
        
        //test
//        rightLabel.backgroundColor = [UIColor lightGrayColor];
//        middleLabel.backgroundColor = [UIColor blueColor];
//        leftLabel.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)updateWithData:(DKCompositeIndexBottomData *)data isLeft:(BOOL)isLeft
{
    if (data == nil) {
        return;
    }
    
    _leftLabel.attributedText = [data walkAttributedString];
    _middleLabel.attributedText = [data heartAttributedString];
    _rightLabel.attributedText = [data allSleepAttributedString];
}

@end
