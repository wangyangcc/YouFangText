//
//  DKUserRecordData.m
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUserRecordData.h"
#import "NSString+extras.h"

@implementation DKUserRecordData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"allSleep" : @"totalSleep",
             };
}

- (NSMutableAttributedString *)walkAttributedString
{
    return [self attributedStringWithValueString:_walk keyString:@"步"];
}

- (NSMutableAttributedString *)distanceAttributedString
{
    return [self attributedStringWithValueString:[NSString formatNumberWithNumStr:_distance?:@"0"] keyString:@"km"];
}

- (NSMutableAttributedString *)heartAttributedString
{
    return [self attributedStringWithValueString:_heart keyString:@"次"];
}

- (NSMutableAttributedString *)lowSleepAttributedString
{
    
    return [self attributedStringWithValueString:[NSString formatNumberWithNumStr:_lowSleep?:@"0"] keyString:@"小时"];
}

- (NSMutableAttributedString *)calorieAttributedString
{
    return [self attributedStringWithValueString:[NSString stringWithFormat:@"%lld",(long long)(round([_calorie doubleValue]?:0))] keyString:@"卡路里"];
}

- (NSMutableAttributedString *)sleepAttributedString
{
    NSInteger sleepMinuteTime = _sleep ? [_sleep integerValue] : 0;
    return [self sleepAttributedWithValueString:[@(sleepMinuteTime/60) stringValue] keyString:@"时" valueStringT:[@(sleepMinuteTime%60) stringValue] keyStringT:@"分"];
}

- (NSMutableAttributedString *)allSleepAttributedString
{
    NSInteger sleepMinuteTime = _allSleep ? [_allSleep integerValue] : 0;
    return [self sleepAttributedWithValueString:[@(sleepMinuteTime/60) stringValue] keyString:@"时" valueStringT:[@(sleepMinuteTime%60) stringValue] keyStringT:@"分"];
}

- (NSMutableAttributedString *)attributedStringWithValueString:(NSString *)valueString
                                                     keyString:(NSString *)keyString
{
    NSString *firstString = [NSString stringWithFormat:@"%@",valueString?:@"0"];
    NSString *secondString = [NSString stringWithFormat:@" %@",keyString?:@""];
    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:27] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DKNavbackcolor range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(14, 15, 16) range:NSMakeRange(firstString.length, secondString.length)];
    return attributedString;
}

- (NSMutableAttributedString *)sleepAttributedWithValueString:(NSString *)valueString
                                                    keyString:(NSString *)keyString
                                                 valueStringT:(NSString *)valueStringT
                                                   keyStringT:(NSString *)keyStringT
{

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    //小时
    NSMutableAttributedString *oneAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",valueString?:@""]];
    [oneAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:27] range:NSMakeRange(0, oneAttributedString.string.length)];
    [oneAttributedString addAttribute:NSForegroundColorAttributeName value:DKNavbackcolor range:NSMakeRange(0, oneAttributedString.string.length)];
    [attributedString appendAttributedString:oneAttributedString];
    
    oneAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",keyString]];
    [oneAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, oneAttributedString.string.length)];
    [oneAttributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(14, 15, 16) range:NSMakeRange(0, oneAttributedString.string.length)];
    [attributedString appendAttributedString:oneAttributedString];
    
    //分钟
    oneAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",valueStringT?:@""]];
    [oneAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:27] range:NSMakeRange(0, oneAttributedString.string.length)];
    [oneAttributedString addAttribute:NSForegroundColorAttributeName value:DKNavbackcolor range:NSMakeRange(0, oneAttributedString.string.length)];
    [attributedString appendAttributedString:oneAttributedString];
    
    oneAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",keyStringT]];
    [oneAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, oneAttributedString.string.length)];
    [oneAttributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(14, 15, 16) range:NSMakeRange(0, oneAttributedString.string.length)];
    [attributedString appendAttributedString:oneAttributedString];
    
    return attributedString;
}

@end
