//
//  DKDataDetailTableViewCell.h
//  DataKit
//
//  Created by wangyangyang on 16/1/8.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKDataDetailViewModel.h"

@interface DKDataDetailTableViewCell : UITableViewCell

- (void)updateWithTitle:(NSString *)title
                content:(NSString *)content
              titleType:(NSString *)titleType
            displayStar:(BOOL)displayStar;

/**
 *  得到月日的格式化日期
 */
+ (NSString *)getMonthDayFormatDateWithDate:(NSDate *)date;

/**
 *  得到用于cell显示的格式化时间
 */
+ (NSString *)getCellDisplayTitleDateWithDate:(NSDate *)date lookType:(DKDataDetailLookType)lookType;

@end
