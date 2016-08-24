//
//  DKHomeTableViewCell.h
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKHomeTableViewCell : UITableViewCell

/**
 *  取值的数值
 */
@property (nonatomic, strong) NSArray *dataIndex;

/**
 *  取值的数值 名称
 */
@property (nonatomic, strong) NSArray *dataIndexName;

/**
 *  取值的单位 名称
 */
@property (nonatomic, strong) NSArray *dataUnitName;

- (BOOL)isDoubleChart;

//根据给定的参数名，得到要取值的参数名数组
+ (NSArray *)doubleChartTypeParametersWithTypeParameter:(NSString *)typeParameter;

///**
// *  图标要现实的单位
// */
//@property (nonatomic, strong) NSArray *dataLineChartName;

@end
