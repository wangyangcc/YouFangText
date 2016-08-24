//
//  DKHomeIndexData.m
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKHomeIndexData.h"
#import "NSString+extras.h"

@implementation DKHomeIndexData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"allSleep" : @"totalSleep",
             };
}


- (NSString *)walkFormat
{
    return [NSString stringWithFormat:@"走了%@步",_walk?:@"0"];
}

- (NSString *)distanceFormat
{
//    NSLog(@"\n2>%@\n2.001>%@\n 2.01>%@\n2.101>%@\n2.151>%@\n2.16>%@",[NSString formatNumberWithNumStr:@"2"],
//          [NSString formatNumberWithNumStr:@"2.001"],
//          [NSString formatNumberWithNumStr:@"2.01"],
//          [NSString formatNumberWithNumStr:@"2.101"],
//          [NSString formatNumberWithNumStr:@"2.151"],
//          [NSString formatNumberWithNumStr:@"2.16"]);
    return [NSString stringWithFormat:@"行走%@公里",[NSString formatNumberWithNumStr:_distance?:@"0"]];
}

- (NSString *)heartFormat
{
    return [NSString stringWithFormat:@"心率BMP%@",_heart?:@"0"];
}

- (NSString *)allSleepFormat
{
    return [NSString stringWithFormat:@"睡了%@",[NSString getSleepHourTimeWithMinuteTime:_allSleep?:@"0"]];
}

- (NSString *)calorieFormat
{
    return [NSString stringWithFormat:@"共消耗%lld大卡",(long long)(round([_calorie doubleValue]?:0))];
}

- (NSString *)bloodFormat
{
    return [NSString stringWithFormat:@"血压%ld/%ldmmHg",(long)[_lblood integerValue], (long)[_hblood integerValue]];
}

- (NSString *)userRecordFormat
{
    return @"个人记录";
}

@end
