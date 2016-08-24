//
//  DKDataDetailViewModel.h
//  DataKit
//
//  Created by wangyangyang on 15/12/31.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DKDataDetailLookType) {
    DKDataDetailLookTypeWeek = 0,
    DKDataDetailLookTypeMouth,
};

/**
 *  用于刷新界面的 数据封装
 */
@interface DKDataDetailViewModel : NSObject

@property (nonatomic, assign) DKDataDetailLookType lookType; /**< 查看的模式，按周，或者月查看 */

/**
 *  图标 坐标数组
 */
@property (nonatomic, strong) NSArray *chartIndex;

/**
 *  图标 值的数组
 */
@property (nonatomic, strong) NSArray *chartValue;

/**
 *  表格显示的数据
 */
@property (nonatomic, strong) NSMutableArray *tableViewData;

/**
 *  表格显示的表头数据
 */
@property (nonatomic, strong) NSMutableArray *tableViewHeaderData;

- (NSArray *)getChartIndexDatesWithEndDate:(NSDate *)endDate chartIndex:(NSArray *)chartIndex;

@end
