//
//  DKDeviceInfo.m
//  DataKit
//
//  Created by wangyangyang on 15/12/7.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDeviceInfo.h"

@implementation DKDeviceInfo

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"serialNumber": @"serialno",
             
             @"bloodPressure": @"bloodp",
             
             @"bloodSugar": @"bloodg",
             
             @"photoPath" : @"photoUrl",
             
             };
}


@end
