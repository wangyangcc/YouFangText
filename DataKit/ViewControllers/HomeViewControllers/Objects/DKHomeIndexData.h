//
//  DKHomeIndexData.h
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKHomeIndexData : MTLModel <MTLJSONSerializing>

/**
 *  步行数
 */
@property (nonatomic, copy) NSString *walk;

/**
 *  运动距离
 */
@property (nonatomic, copy) NSString *distance;

/**
 *  心率
 */
@property (nonatomic, copy) NSString *heart;

/**
 *  浅睡眠
 */
@property (nonatomic, copy) NSString *lowSleep;

/**
 *  卡路里值
 */
@property (nonatomic, copy) NSString *calorie;

/**
 *  深睡眠
 */
@property (nonatomic, copy) NSString *sleep;

/**
 *  总的睡眠
 */
@property (nonatomic, copy) NSString *allSleep;

/**
 *  个人记录
 */
@property (nonatomic, copy) NSString *userRecord;

//血压
@property (nonatomic, copy) NSString *blood;

//低压
@property (nonatomic, copy) NSString *lblood;

//高压
@property (nonatomic, copy) NSString *hblood;

/**
 *  步行数
 */
@property (nonatomic, copy) NSString *walkFormat;

/**
 *  运动距离
 */
@property (nonatomic, copy) NSString *distanceFormat;

/**
 *  心率
 */
@property (nonatomic, copy) NSString *heartFormat;

/**
 *  浅睡眠
 */
@property (nonatomic, copy) NSString *lowSleepFormat;

/**
 *  卡路里值
 */
@property (nonatomic, copy) NSString *calorieFormat;

/**
 *  深睡眠
 */
@property (nonatomic, copy) NSString *sleepFormat;

/**
 *  总的睡眠
 */
@property (nonatomic, copy) NSString *allSleepFormat;

/**
 *  个人记录
 */
@property (nonatomic, copy) NSString *userRecordFormat;

//血压
@property (nonatomic, copy) NSString *bloodFormat;

//低压
@property (nonatomic, copy) NSString *lbloodFormat;

//高压
@property (nonatomic, copy) NSString *hbloodFormat;

@end
