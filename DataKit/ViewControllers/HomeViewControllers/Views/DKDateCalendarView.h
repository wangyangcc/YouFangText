//
//  DKDateCalendarView.h
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKDateCalendarView : UIView

/**
 *  确定查看的日期
 */
@property (copy) void (^lookDate)(NSDate *lookDate);

- (BOOL)isShowed;

- (void)showWithSelectedDate:(NSDate *)selectedDate;

- (void)hide;

@end
