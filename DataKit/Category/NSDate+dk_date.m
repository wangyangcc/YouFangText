//
//  NSDate+dk_date.m
//  DataKit
//
//  Created by wangyangyang on 16/3/29.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "NSDate+dk_date.h"

@implementation NSDate (dk_date)

+ (NSDate *)dk_date
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    return [date  dateByAddingTimeInterval: interval];
}

@end
