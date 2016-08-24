//
//  NSString+extras.m
//  Datakit
//
//  Created by wangyangyang on 15/7/21.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "NSString+extras.h"
#import "NSDictionary+Extras.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (extras)

-(BOOL) isEmpty {
    
    return 0==self.length
    || 0==[[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    
}

- (NSString *)stringByAppendingQueryParameters:(NSDictionary *)queryParameters
{
    if ([queryParameters count] > 0 && [self rangeOfString:@"?"].length > 0) {
        return [NSString stringWithFormat:@"%@&%@", self, [queryParameters stringFromQueryParams]];
    }
    else {
        return [NSString stringWithFormat:@"%@?%@", self, [queryParameters stringFromQueryParams]];
    }
    return [NSString stringWithString:self];
}

- (NSString *) stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (NSString *)stringByReplacingURLEncoding
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray *)keyValueArrayFromQuery {
    NSString* decodedQuery = [self stringByReplacingURLEncoding];
    NSRange range = [decodedQuery rangeOfString:@"?"];
    
    NSString *trimmedQuery;
    if (range.length == 0) {
        range = [decodedQuery rangeOfString:@".com"];
        trimmedQuery = [decodedQuery substringFromIndex:range.location + range.length + 1];
    } else {
        trimmedQuery = [decodedQuery substringFromIndex:range.location + range.length];
    }
    
    trimmedQuery = [trimmedQuery stringByReplacingOccurrencesOfString:@" & " withString:@" and "];
    NSArray *keyValues = [trimmedQuery componentsSeparatedByString:@"&"];
    return keyValues;
}

- (NSString*)urlEncodedString {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (CFStringRef)self,
                                                                     NULL,
                                                                     (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (NSString*)urlDecodedString {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//时间显示内容
+ (NSString *)getDateDisplayString:(long long) miliSeconds
{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"今天 HH:mm:ss";
        } else if((nowCmps.day-myCmps.day)==1) {
            dateFmt.dateFormat = @"昨天 HH:mm:ss";
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
}

//格式化数字
+ (NSString *)formatNumberWithNumStr:(NSString *)numStr
{
    if (numStr == nil) {
        return @"";
    }

    double dest = [numStr doubleValue];
    NSInteger destInt = (NSInteger)dest;
    
    //获取小数部分
    double decimalPart = dest - destInt;
    //判断小数部分是否大于0.1
    if(decimalPart*10 < 1 && decimalPart*10 != 0)
    {
        dest = destInt + 0.1;
    }
    else
    {
        dest = round(dest*10)/10.0;
    }
    
    return [NSString stringWithFormat:@"%.1f",dest];
}

//得到睡眠的小时显示格式，根据分钟数量
+ (NSString *)getSleepHourTimeWithMinuteTime:(NSString *)minuteTime
{
    NSInteger sleepMinuteTime = minuteTime ? [minuteTime integerValue] : 0;
    return [NSString stringWithFormat:@"%ld时%ld分",sleepMinuteTime/60,sleepMinuteTime%60];
}

//得到睡眠的小时显示格式，根据分钟数量
+ (NSString *)getSleepHourTimeWithMinuteTimeT:(NSString *)minuteTime
{
    NSInteger sleepMinuteTime = minuteTime ? [minuteTime integerValue] : 0;
    return [NSString stringWithFormat:@"%ld时%ld分",sleepMinuteTime/60,sleepMinuteTime%60];
}

@end
