//
//  NSString+extras.h
//  Datakit
//
//  Created by wangyangyang on 15/7/21.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (extras)

- (BOOL)isEmpty;

- (NSString*)stringFromMD5;

- (NSString*)urlEncodedString;

- (NSString*)urlDecodedString;

- (NSString*)stringByAppendingQueryParameters:(NSDictionary *)queryParameters;

- (NSString*)stringByReplacingURLEncoding;

- (NSArray*)keyValueArrayFromQuery;

//时间显示内容
+ (NSString *)getDateDisplayString:(long long) miliSeconds;

//格式化数字
+ (NSString *)formatNumberWithNumStr:(NSString *)numStr;

//得到睡眠的小时显示格式，根据分钟数量 x小时y分钟
+ (NSString *)getSleepHourTimeWithMinuteTime:(NSString *)minuteTime;

//得到睡眠的小时显示格式，根据分钟数量 xhym
+ (NSString *)getSleepHourTimeWithMinuteTimeT:(NSString *)minuteTime;

@end
