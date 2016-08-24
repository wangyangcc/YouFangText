//
//  DKDataDetailViewModel.m
//  DataKit
//
//  Created by wangyangyang on 15/12/31.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDataDetailViewModel.h"

@implementation DKDataDetailViewModel


- (NSMutableArray *)tableViewData
{
    if (_tableViewData == nil) {
        _tableViewData = [NSMutableArray array];
    }
    return _tableViewData;
}

- (NSMutableArray *)tableViewHeaderData
{
    if (_tableViewHeaderData == nil) {
        _tableViewHeaderData = [NSMutableArray array];
    }
    return _tableViewHeaderData;
}

- (NSArray *)getChartIndexDatesWithEndDate:(NSDate *)endDate chartIndex:(NSArray *)chartIndex
{
    if (endDate == nil || chartIndex == nil) {
        return @[];
    }
    NSMutableArray *array = [NSMutableArray array];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *lastDateStr = [formatter stringFromDate:endDate];
    [chartIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@",lastDateStr,obj];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [array addObject:[formatter dateFromString:dateStr]];
    }];
    return array;
}

@end
