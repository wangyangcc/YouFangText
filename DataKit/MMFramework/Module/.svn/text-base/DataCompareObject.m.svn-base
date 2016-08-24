//
//  DataCompareObject.m
//  SanMen
//
//  Created by lcc on 14-1-13.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import "DataCompareObject.h"

@implementation DataCompareObject

+ (int)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *dateA = [dateFormatter dateFromString:oneDay];
    NSDate *dateB = [dateFormatter dateFromString:anotherDay];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending)
    {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending)
    {
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
}

+ (NSString *) getCurrentTimeWithFormate:(NSString *) formateString
{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formateString];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    return locationString;
}

@end
