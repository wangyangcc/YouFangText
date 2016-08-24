//
//  DKCompositeIndexView.m
//  DataKit
//
//  Created by wangyangyang on 15/12/2.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCompositeIndexView.h"
#import "AFCircleChart.h"

@interface DKCompositeIndexView ()
{
    AFCircleChart *circleChartSmall;
    AFCircleChart *circleChartBig;

    BOOL isUpdated;/**是否刷新过*/
}

@end

@implementation DKCompositeIndexView

- (instancetype)initWithFrame:(CGRect)frame isLeft:(BOOL)isLeft
{
    self = [super initWithFrame:frame];
    if (self) {
        //大圈
        CGRect bigRect = CGRectMake((CGRectGetWidth(frame) - 232)/2, [MetaData valueForDeviceCun3_5:49 cun4:49 cun4_7:40 cun5_5:59], 232, 232);
        circleChartBig = [[AFCircleChart alloc] initWithFrame:bigRect lineWidth:17 chartImage:isLeft?@"left_circle_big":@"right_circle_big"]; //边框17
        circleChartBig.backgroundColor = [UIColor clearColor];
        circleChartBig.bottomLayerColor = [UIColor whiteColor];
        [circleChartBig setTextIconImage:isLeft?@"jrbu":@"jrgh"];
        [self addSubview:circleChartBig];
        //end
        
        //添加背景阴影
        UIImageView *blImageView = [UIImageView new];
        blImageView.image = [UIImage imageNamed:@"circle_shadow"];
        [self insertSubview:blImageView belowSubview:circleChartBig];
        blImageView.frame = CGRectMake(CGRectGetMinX(circleChartBig.frame) - (261-232)/2, CGRectGetMinY(circleChartBig.frame) - (261-232)/2, 261, 261);
        //end
        
        //小圈
        CGRect smallRect = CGRectMake((CGRectGetWidth(frame) - 198)/2, [MetaData valueForDeviceCun3_5:65.5 cun4:65.5 cun4_7:57 cun5_5:76.5], 198, 198);
        circleChartSmall = [[AFCircleChart alloc] initWithFrame:smallRect lineWidth:16 chartImage:isLeft?@"left_circle_big":@"right_circle_big"];
        circleChartSmall.backgroundColor = [UIColor clearColor];
        circleChartSmall.bottomLayerColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        [self addSubview:circleChartSmall];
        [circleChartSmall setTextIconImage:isLeft?@"pjbs":@"pjgh"];
        //end
        

        if (isLeft) {
            [circleChartSmall setLabelAttributedString:[self getLabelAttributedStringWithSignString:@"..." bigNumber:nil smallNumber:nil isLeft:isLeft] labelFrame:CGRectMake(15, 30, CGRectGetWidth(circleChartSmall.bounds) - 30, CGRectGetHeight(circleChartSmall.bounds) - 40)];
        }
    }
    return self;
}

/**
 *  更新试图
 *
 *  @param bigNumber   大圈数字
 *  @param smallNumber 小圈数字
 */
- (void)updateViewWithBigNumber:(NSString *)bigNumber
                    smallNumber:(NSString *)smallNumber
                     signString:(NSString *)signString
                         isLeft:(BOOL)isLeft
{
    if (bigNumber == nil || smallNumber == nil || isUpdated) {
        return;
    }
    
    isUpdated = YES;
    
    NSInteger bigNum = [bigNumber integerValue];
    if (bigNum > 0 && bigNum < 2) {
        bigNum = 2;
    }
    NSInteger smallNum = [smallNumber integerValue];
    if (smallNum > 0 && smallNum < 2) {
        smallNum = 2;
    }
    
    [circleChartBig setAtValue:bigNum totalValue:kTotalValue];
    [circleChartSmall setAtValue:smallNum totalValue:kTotalValue];
    
    [circleChartSmall setLabelAttributedString:[self getLabelAttributedStringWithSignString:signString bigNumber:bigNumber smallNumber:smallNumber isLeft:isLeft] labelFrame:CGRectMake(15, 23, CGRectGetWidth(circleChartSmall.bounds) - 30, CGRectGetHeight(circleChartSmall.bounds) - 40)];
    
    [circleChartBig animatePath];
    [circleChartSmall animatePath];
}

- (NSMutableAttributedString *)getLabelAttributedStringWithSignString:(NSString *)signString
                                                            bigNumber:(NSString *)bigNumber
                                                          smallNumber:(NSString *)smallNumber
                                                               isLeft:(BOOL)isLeft
{
    NSString *firstString = signString?[signString stringByAppendingString:@"\n"]:@"";
    NSString *secondString = bigNumber?:@"";
    NSString *thirdString = smallNumber?[NSString stringWithFormat:@"\n历史 %@",smallNumber]:@"";
    NSString *allString = [NSString stringWithFormat:@"%@%@%@",firstString,secondString,thirdString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:110/255.0 green:111/255.0 blue:112/255.0 alpha:1] range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:45] range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:185/255.0 green:107/255.0 blue:204/255.0 alpha:1] range:NSMakeRange(firstString.length, secondString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(firstString.length + secondString.length, thirdString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:144/255.0 green:145/255.0 blue:146/255.0 alpha:1] range:NSMakeRange(firstString.length + secondString.length, thirdString.length)];
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.alignment = NSTextAlignmentCenter;
    parStyle.paragraphSpacing = 8;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, firstString.length + secondString.length)];
    
    parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.alignment = NSTextAlignmentCenter;
    parStyle.paragraphSpacing = 15;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(firstString.length + secondString.length, thirdString.length)];
    return attributedString;
}

@end
