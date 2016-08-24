//
//  NSObject+dateFormat.m
//  DataKit
//
//  Created by wangyangyang on 15/12/28.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "NSObject+dateFormat.h"

@implementation NSObject (dateFormat)

/**
 *  得到今天的年月日date
 */
+ (NSDate *)toadyFormatDate
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:[NSDate dk_date]];
    dateStr = [dateStr stringByAppendingString:@" 00:00:01"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:dateStr];
}

/**
 *  得到date的格式化日期
 */
+ (NSDate *)formatDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    dateStr = [dateStr stringByAppendingString:@" 00:00:01"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:dateStr];
}

/**
 *  得到首页显示的文字
 */
+ (NSString *)homeTitleFormatStringWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    return [formatter stringFromDate:date];
}

/**
 *  网页请求参数
 */
+ (NSString *)requestParameterFormatDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [formatter stringFromDate:date];
}

/**
 *  网页请求参数
 */
+ (NSString *)requestParameterFormatHourDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyyMMddHH"];
    return [formatter stringFromDate:date];
}

/**
 *  昨天的格式化时间
 */
+ (NSDate *)yesterdayFormatDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    double withNowInterval = [date timeIntervalSince1970];
    //得到昨天的时间
    NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSince1970:withNowInterval - 24*60*60];
    return yesterdayDate;
}

/**
 *  明天的格式化时间
 */
+ (NSDate *)tomorrowFormatDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    double withNowInterval = [date timeIntervalSince1970];
    //得到昨天的时间
    NSDate *tomorrowDate = [NSDate dateWithTimeIntervalSince1970:withNowInterval + 24*60*60];
    return tomorrowDate;
}

/**
 *  得到本周末的格式化时间
 */
+ (NSDate *)thisWeekEndFormatDate
{
    NSDate *todayDate = [NSObject toadyFormatDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *comp = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit fromDate:todayDate];
    
    NSInteger weekDay = [comp weekday]; // 获取今天是周几
    
    NSInteger day = [comp day]; // 获取几天是几号
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff;
    if (weekDay == 1)
    {
        firstDiff = -6;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
    }

    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *endDayComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:todayDate];
    [endDayComp setDay:day + firstDiff + 6];
    NSDate *endDayOfWeek = [calendar dateFromComponents:endDayComp];
    return endDayOfWeek;
}

/**
 *  判断是不是同一月
 *
 */
+ (BOOL)isSameMonthWithOneDate:(NSDate *)date otherDate:(NSDate *)otherDate
{
    if (date == nil || otherDate == nil) {
        return NO;
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"MM"];
    
    NSString *oneDateMonthStr = [formatter stringFromDate:date];
    NSString *twoDateMonthStr = [formatter stringFromDate:otherDate];
    return [oneDateMonthStr isEqualToString:twoDateMonthStr];
}

/**
 *  对于给定的时间，得到上个周/下个周 周末的时间
 */
+ (NSDate *)getWeekEndFormatDateWithDate:(NSDate *)date
                                  isLast:(BOOL)isLast
{
    if (date == nil) {
        return nil;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *dateComp = [calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSInteger dateWeekDay = [dateComp weekday]; // 给定的date是周几
    NSInteger dateDay = [dateComp day]; // 给定的date是几号

    long dateWeakFirstDayDiff;// 用于计算 给定的date所在的周一
    if (dateWeekDay == 1)
    {
        dateWeakFirstDayDiff = -6;
    }
    else
    {
        dateWeakFirstDayDiff = [calendar firstWeekday] - dateWeekDay + 1;
    }
    
    //计算给定的date 上周末  或者  下周末 的时间
    NSDateComponents *resultWeekEndDateComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:date];
    [resultWeekEndDateComp setDay:dateDay + dateWeakFirstDayDiff + (isLast? -1 : 13 )];
    NSDate *resultWeekEndDate = [calendar dateFromComponents:resultWeekEndDateComp];
    return resultWeekEndDate;
}

/**
 *  对于给定的时间，得到上个月/下个月 周底的时间
 */
+ (NSDate *)getMonthEndFormatDateWithDate:(NSDate *)date
                                   isLast:(BOOL)isLast
{
    if (date == nil) {
        return nil;
    }
    NSDate *monthFirstDayOfDate = nil;
    //得到给定 date 月初的时间
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"yyyy-MM"];
        NSString *dateStr = [formatter stringFromDate:date];
        dateStr = [dateStr stringByAppendingString:@"-01 00:00:01"];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        monthFirstDayOfDate = [formatter dateFromString:dateStr];
    }
    //end
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    //如果是计算下个月 月末的时间，则得到两个月后 月初的时间
    if (isLast == NO) {
        NSDateComponents *comp = [calendar components:NSMonthCalendarUnit fromDate:date];
        NSInteger month = [comp month];
        
        NSDateComponents *endDayComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:monthFirstDayOfDate];
        [endDayComp setMonth:month + 2];
        monthFirstDayOfDate = [calendar dateFromComponents:endDayComp];
    }

    //月初时间是哪一天
    NSDateComponents *monthFirstDayDatecomp = [calendar components:NSDayCalendarUnit fromDate:monthFirstDayOfDate];
    NSInteger monthFirstDay = [monthFirstDayDatecomp day];
    
    NSDateComponents *resultDatecomp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:monthFirstDayOfDate];
    [resultDatecomp setDay:monthFirstDay - 1];
    NSDate *monthEndDayDate = [calendar dateFromComponents:resultDatecomp];
    return monthEndDayDate;
}

/**
 *  根据 周末 时间 得到周一时间
 */
+ (NSDate *)getWeekFirstDateWithWeekEndDate:(NSDate *)weekEndDate
{
    if (weekEndDate == nil) {
        return nil;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *weekEndDateComp = [calendar components:NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:weekEndDate];
    NSInteger weekEndDateDay = [weekEndDateComp day];
    NSInteger weekEndDateWeek = [weekEndDateComp weekday];

    long dateWeakFirstDayDiff;// 用于计算 给定的date所在的周一
    if (weekEndDateWeek == 1)
    {
        dateWeakFirstDayDiff = -6;
    }
    else
    {
        dateWeakFirstDayDiff = [calendar firstWeekday] - weekEndDateWeek + 1;
    }

    NSDateComponents *resultWeekFirstDateComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:weekEndDate];
    [resultWeekFirstDateComp setDay:weekEndDateDay + dateWeakFirstDayDiff];
    NSDate *resultWeekFirstDate = [calendar dateFromComponents:resultWeekFirstDateComp];
    return resultWeekFirstDate;
}

/**
 *  根据 月末 时间 得到月初时间
 */
+ (NSDate *)getMonthFirstDateWithMonthEndDate:(NSDate *)monthEndDate
{
    if (monthEndDate == nil) {
        return nil;
    }

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *dateStr = [formatter stringFromDate:monthEndDate];
    dateStr = [dateStr stringByAppendingString:@"-01 00:00:01"];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:dateStr];
}

/**
 *  根据 月中的一天 得到月末时间
 */
+ (NSDate *)getMonthLastDateWithMonthOneDate:(NSDate *)monthOneDate
{
    if (monthOneDate == nil) {
        return nil;
    }
    
    NSDate *monthFirstDayOfDate = nil;
    //得到给定 date 月初的时间
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"yyyy-MM"];
        NSString *dateStr = [formatter stringFromDate:monthOneDate];
        dateStr = [dateStr stringByAppendingString:@"-01 00:00:01"];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        monthFirstDayOfDate = [formatter dateFromString:dateStr];
    }
    //end
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    //计算下个月 月初的时间
    NSDateComponents *comp = [calendar components:NSMonthCalendarUnit fromDate:monthFirstDayOfDate];
    NSInteger month = [comp month];
    
    NSDateComponents *endDayComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:monthFirstDayOfDate];
    [endDayComp setMonth:month + 1];
    monthFirstDayOfDate = [calendar dateFromComponents:endDayComp];

    NSDate *resultDate = [[NSDate alloc] initWithTimeInterval:-24*60*60 sinceDate:monthFirstDayOfDate];
    return resultDate;
}

/**
 *  根据结束时间，得到一周每天的格式化时间
 */
+ (NSMutableArray *)getWeekEveryDaysWithEndDate:(NSDate *)endDate
{
    if (endDate == nil) {
        return [@[] mutableCopy];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *weekEndDateComp = [calendar components:NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:endDate];
    NSInteger weekEndDateDay = [weekEndDateComp day];
    
    NSMutableArray *resultDays = [NSMutableArray array];
    for (NSInteger index = 1; index < 8; index ++) {
        
        NSDateComponents *resultWeekFirstDateComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:endDate];
        [resultWeekFirstDateComp setDay:weekEndDateDay - index];
        NSDate *frontWeekDate = [calendar dateFromComponents:resultWeekFirstDateComp];
        NSDateComponents *frontWeekDateComp = [calendar components:NSWeekdayCalendarUnit  fromDate:frontWeekDate];
        NSInteger frontWeekDateWeek = [frontWeekDateComp weekday];
        if (frontWeekDateWeek == 1) {
            break;
        }
        [resultDays insertObject:frontWeekDate atIndex:[resultDays count]];
    }
    
    [resultDays insertObject:endDate atIndex:0];
    
    return resultDays;
}

@end
