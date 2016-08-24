//
//  DKDataDetailHourData.m
//  DataKit
//
//  Created by wangyangyang on 16/1/8.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "DKDataDetailHourData.h"

@implementation DKDataDetailHourData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"dayDate": @"hour",
             
             @"dayData": @"hourData",
             
             };
}

@end
