//
//  NSObject+dateFormat.h
//  DataKit
//
//  Created by wangyangyang on 15/12/28.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKDataDetailViewModel.h"

@interface NSObject (dateFormat)

/**
 *  得到今天的年月日date
 */
+ (NSDate *)toadyFormatDate;

/**
 *  网页请求参数
 */
+ (NSString *)requestParameterFormatDateWithDate:(NSDate *)date;

/**
 *  网页请求参数
 */
+ (NSString *)requestParameterFormatHourDateWithDate:(NSDate *)date;

#pragma mark - 首页

/**
 *  得到date的格式化日期
 */
+ (NSDate *)formatDateWithDate:(NSDate *)date;

/**
 *  得到首页显示的文字
 */
+ (NSString *)homeTitleFormatStringWithDate:(NSDate *)date;

/**
 *  昨天的格式化时间
 */
+ (NSDate *)yesterdayFormatDateWithDate:(NSDate *)date;

/**
 *  明天的格式化时间
 */
+ (NSDate *)tomorrowFormatDateWithDate:(NSDate *)date;

#pragma mark - 详情界面

/**
 *  得到本周末的格式化时间
 */
+ (NSDate *)thisWeekEndFormatDate;

/**
 *  判断是不是同一月
 *
 */
+ (BOOL)isSameMonthWithOneDate:(NSDate *)date otherDate:(NSDate *)otherDate;

/**
 *  对于给定的时间，得到上个周/下个周 周末的时间
 */
+ (NSDate *)getWeekEndFormatDateWithDate:(NSDate *)date
                                  isLast:(BOOL)isLast;

/**
 *  对于给定的时间，得到上个月/下个月 周底的时间
 */
+ (NSDate *)getMonthEndFormatDateWithDate:(NSDate *)date
                                  isLast:(BOOL)isLast;

/**
 *  根据 周末 时间 得到周一时间
 */
+ (NSDate *)getWeekFirstDateWithWeekEndDate:(NSDate *)weekEndDate;

/**
 *  根据 月末 时间 得到月初时间
 */
+ (NSDate *)getMonthFirstDateWithMonthEndDate:(NSDate *)monthEndDate;

/**
 *  根据 月中的一天 得到月末时间
 */
+ (NSDate *)getMonthLastDateWithMonthOneDate:(NSDate *)monthOneDate;

/**
 *  根据结束时间，得到一周每天的格式化时间
 */
+ (NSMutableArray *)getWeekEveryDaysWithEndDate:(NSDate *)endDate;


@end
