//
//  DKDataDetailViewController.h
//  DataKit
//
//  Created by wangyangyang on 15/12/4.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "GeneralSuperViewController.h"
#import "DKDataDetailViewModel.h"

@interface DKDataDetailViewController : GeneralSuperViewController

- (id)initDayDetailModelWithHourDatas:(NSDictionary *)hourDatas dayDate:(NSDate *)dayDate;

@property (nonatomic, readonly, assign) BOOL dayDetailModel; /**< 查看天详情模式 */

/**
 *   详情查看的类型名
 */
@property (nonatomic, copy) NSString *detailTypeName;

/**
 *   详情查看的单位名
 */
@property (nonatomic, copy) NSString *detailUnitName;

/**
 *   详情查看的类型 反射 参数名
 */
@property (nonatomic, copy) NSString *detailTypeParameter;

//是否是两种表格
@property (nonatomic, assign) BOOL isDoubleChart;

@end
