//
//  DKSerialDayData.h
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"
#import "DKUserSportIndex.h"

@interface DKSerialDayData : MTLModel <MTLJSONSerializing>

/**
 *  日期
 */
@property (nonatomic, copy) NSString *dateStr;

/**
 *  天数据
 */
@property (nonatomic, copy) DKUserSportIndex *dayData;

/**
 *  小时数据
 */
@property (nonatomic, copy) DKUserSportIndex *hourDatas;

@end
