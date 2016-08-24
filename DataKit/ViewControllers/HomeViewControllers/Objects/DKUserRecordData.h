//
//  DKUserRecordData.h
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKUserRecordData : MTLModel <MTLJSONSerializing>

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

//总睡眠
@property (nonatomic, copy) NSString *allSleep;

- (NSMutableAttributedString *)walkAttributedString;

- (NSMutableAttributedString *)distanceAttributedString;

- (NSMutableAttributedString *)heartAttributedString;

- (NSMutableAttributedString *)lowSleepAttributedString;

- (NSMutableAttributedString *)calorieAttributedString;

- (NSMutableAttributedString *)sleepAttributedString;

- (NSMutableAttributedString *)allSleepAttributedString;

@end
