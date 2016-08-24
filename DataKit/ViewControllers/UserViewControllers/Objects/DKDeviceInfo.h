//
//  DKDeviceInfo.h
//  DataKit
//
//  Created by wangyangyang on 15/12/7.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKDeviceInfo : MTLModel <MTLJSONSerializing>

/**
 *  序列号
 */
@property (nonatomic, copy) NSString *serialNumber;

/**
 *  用户性别 1:女  2: 男
 */
@property (nonatomic, assign) NSInteger sex;

/**
 *  用户头像
 */
@property (nonatomic, copy) NSString *photoPath;

/**
 *  和我的关系
 */
@property (nonatomic, copy) NSString *relation;

/**
 *  用户身高
 */
@property (nonatomic, copy) NSString *height;

/**
 *  用户体重
 */
@property (nonatomic, copy) NSString *weight;

/**
 *  用户生日
 */
@property (nonatomic, copy) NSString *birthday;

/**
 *  用户血压
 */
@property (nonatomic, copy) NSString *bloodPressure;

/**
 *  用户血糖
 
 */
@property (nonatomic, copy) NSString *bloodSugar;

/**
 *  勿扰时间段
 */
@property (nonatomic, copy) NSString *nobreaktime;

/**
 *  错误编码，详见 [DKClientRequest errorCodeDic]
 */
@property (nonatomic, copy) NSNumber *errorCode;

/*!运动目标 步数#睡眠时长 */
@property (copy, nonatomic) NSString *target;

/**
 *  是否成功
 */
@property (nonatomic, assign) BOOL isSuccess;

@end
