//
//  DKCompositeIndexBottomData.m
//  DataKit
//
//  Created by wangyangyang on 15/12/27.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCompositeIndexBottomData.h"
#import "NSString+extras.h"

@implementation DKCompositeIndexBottomData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"allSleep" : @"totalSleep"
             };
}

- (NSMutableAttributedString *)walkAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%@",_walk?:@"0"] keyString:@"计步"];
}

- (NSMutableAttributedString *)distanceAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%0.1f",[_distance floatValue]] keyString:@"距离:公里"];
}

- (NSMutableAttributedString *)heartAttributedString
{
    return [self attributedStringWithValueString:_heart keyString:@"心率"];
}

- (NSMutableAttributedString *)lowSleepAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%0.1f",[_lowSleep floatValue]] keyString:@"浅睡眠:小时"];
}

- (NSMutableAttributedString *)calorieAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%0.1f",[_calorie floatValue]] keyString:@"消耗:卡"];
}

- (NSMutableAttributedString *)sleepAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%0.1f",[_sleep floatValue]] keyString:@"深睡眠:小时"];
}

- (NSMutableAttributedString *)allSleepAttributedString
{
    return [self attributedStringWithValueString:[NSString getSleepHourTimeWithMinuteTime:_allSleep?:@"0"] keyString:@"睡眠总时长"];
}

- (NSMutableAttributedString *)attributedStringWithValueString:(NSString *)valueString
                                                     keyString:(NSString *)keyString
{
    NSString *firstString = [NSString stringWithFormat:@"%@\n",valueString == nil? @"0" : valueString];
    NSString *secondString = [NSString stringWithFormat:@"%@",keyString];
    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DKNavbackcolor range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(153, 153, 153) range:NSMakeRange(firstString.length, secondString.length)];
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.lineSpacing = 3;
    parStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

@end
