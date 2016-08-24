//
//  DKSerialDayData.m
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKSerialDayData.h"

@implementation DKSerialDayData

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"dateStr": @"day",
             
             };
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    DKSerialDayData *model = [super modelWithDictionary:dictionary error:error];
    if (model) {
        if ([[dictionary allKeys] containsObject:@"dayData"]) {
            NSError *error = nil;
            DKUserSportIndex *modelObj = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKUserSportIndex") fromJSONDictionary:[dictionary objectForKey:@"dayData"] error:&error];
            model.dayData = modelObj;
        }
        if ([[dictionary allKeys] containsObject:@"hourDatas"]) {
            NSError *error = nil;
            DKUserSportIndex *modelObj = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKUserSportIndex") fromJSONDictionary:[dictionary objectForKey:@"hourDatas"] error:&error];
            model.hourDatas = modelObj;
        }
    }
    return (DKSerialDayData *)model;
}

@end
