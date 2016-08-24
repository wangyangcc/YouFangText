//
//  DKDataDetailDayData.m
//  DataKit
//
//  Created by wangyangyang on 15/12/31.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDataDetailDayData.h"
#import "NSString+extras.h"

@implementation DKDataDetailDayData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"dayDate": @"day",
             
             @"dayHourDatas": @"hourDatas",
             
             };
}

- (NSString *)detailTypeValue
{
    if (self.detailTypeParameter == nil) {
        return @"0";
    }
    if (self.dayData == nil) {
        return @"0";
    }
    //心率单独取值
    if ([self.detailTypeParameter isEqualToString:@"heart"]) {
        return self.avgHeart?[self.avgHeart stringValue]:@"0";
    }
    //睡眠单独计算
    if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
        NSInteger sleepMinuteTime = self.dayData[@"totalSleep"] ? [self.dayData[@"totalSleep"] integerValue] : 0;
        return [NSString stringWithFormat:@"%ld",sleepMinuteTime];
    }
    //血压单独计算
    if ([self.detailTypeParameter isEqualToString:@"blood"]) {
        return [NSString stringWithFormat:@"%ld/%ld",(long)[_avgLblood integerValue], (long)[_avgHblood integerValue]];
    }
    //end
    //行走单独计算
    if ([self.detailTypeParameter isEqualToString:@"distance"]) {
        return [NSString formatNumberWithNumStr:self.dayData[@"distance"]];
    }
    return [DKDataDetailDayData aveFormatNumber:self.dayData[self.detailTypeParameter] detailTypeParameter:self.detailTypeParameter];
}

+ (BOOL)isLongValueWithDetailTypeParameter:(NSString *)detailTypeParameter
{
    if (detailTypeParameter == nil) {
        return NO;
    }
    if ([detailTypeParameter isEqualToString:@"walk"] || [detailTypeParameter isEqualToString:@"heart"] || [detailTypeParameter isEqualToString:@"calorie"]) {
        return YES;
    }
    return NO;
}

//平均值的格式化
+ (NSString *)aveFormatNumber:(NSString *)number detailTypeParameter:(NSString *)detailTypeParameter
{
    if (detailTypeParameter == nil || number == nil) {
        return @"0";
    }
    //行走和睡眠保留小数
    if ([detailTypeParameter isEqualToString:@"distance"] || [detailTypeParameter isEqualToString:@"allSleep"]) {
        return [NSString stringWithFormat:@"%.1f",[number floatValue]];
    }
    //四舍五入
    double numberDou = [number doubleValue];
    return [NSString stringWithFormat:@"%lld",(long long)(round(numberDou))];
}

@end
