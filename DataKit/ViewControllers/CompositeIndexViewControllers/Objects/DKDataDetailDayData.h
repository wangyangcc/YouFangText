//
//  DKDataDetailDayData.h
//  DataKit
//
//  Created by wangyangyang on 15/12/31.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKDataDetailDayData : MTLModel <MTLJSONSerializing>

/**
 *  天的日期
 */
@property (nonatomic, copy) NSString *dayDate;

/**
 *  天的数据
 */
@property (nonatomic, copy) NSDictionary *dayData;

/**
 *  根据反射查看对应参数名的数据
 */
@property (nonatomic, copy) NSString *detailTypeValue;

/**
 *   详情查看的类型 反射 参数名
 */
@property (nonatomic, copy) NSString *detailTypeParameter;

/**
 *  天的小数数据
 */
@property (nonatomic, strong) NSDictionary *dayHourDatas;

//avgHeart
@property (nonatomic, strong) NSNumber *avgHeart;

//天/小时 血压平均低压
@property (nonatomic, strong) NSNumber *avgLblood;

//天/小时 血压平均高压
@property (nonatomic, strong) NSNumber *avgHblood;

+ (BOOL)isLongValueWithDetailTypeParameter:(NSString *)detailTypeParameter;

//平均值的格式化
+ (NSString *)aveFormatNumber:(NSString *)number detailTypeParameter:(NSString *)detailTypeParameter;

@end
