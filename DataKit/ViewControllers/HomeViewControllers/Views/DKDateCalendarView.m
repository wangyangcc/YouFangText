//
//  DKDateCalendarView.m
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDateCalendarView.h"
#import "JTCalendar.h"
#import "GeneralSuperViewController.h"

@interface DKDateCalendarView () <JTCalendarDelegate>
{
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;
    
    BOOL isShowed;
}

@property (nonatomic, strong) UIImageView *co_contentTopImageView;
@property (nonatomic, strong) UIView *co_contentView;

@property (nonatomic, strong) UILabel *co_todayDateLeftLabel; //**< 今天时间 左边label */
@property (nonatomic, strong) UILabel *co_todayDateRightLabel; //**< 今天时间 右边label */

@property (nonatomic, strong) UIView *co_indicateDateView; //**< 指示时间view */
@property (nonatomic, strong) UILabel *co_indicateDateLabel; //**< 指示出的时间 */
@property (nonatomic, strong) UIButton *co_indicateDateRightButton; //**< 指示时间 右边按钮*/

/**
 *  日期选择
 */
@property (nonatomic, strong) JTCalendarManager *calendarManager;
@property (strong, nonatomic) JTHorizontalCalendarView *calendarContentView;

@property (nonatomic, strong) UIView *co_bottomButtonView; /**< 底部的两个按钮 */

@end

@implementation DKDateCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //内容载体
        self.co_contentView.frame = CGRectMake(0, - CGRectGetHeight(self.frame) + MMNavigationBarHeight, ScreenWidth, ScreenHeight - MMNavigationBarHeight);
        [self addSubview:self.co_contentView];
        //end
        
        //顶部颜色
        self.co_contentTopImageView = [UIImageView new];
        [self addSubview:self.co_contentTopImageView];
        self.co_contentTopImageView.userInteractionEnabled = YES;
        self.co_contentTopImageView.frame = CGRectMake(0, 0, ScreenWidth, IOS7AFTER ? 64 : 44);
        [_co_contentTopImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
        //end
        
        //添加最上方的指示的时间
        CGFloat toDayTimeTop = [MetaData isIphone4_4s] ? -5: 15;
        [self.co_contentView addSubview:self.co_todayDateLeftLabel];
        [self.co_todayDateLeftLabel autoSetDimensionsToSize:CGSizeMake(100, 88)];
        [self.co_todayDateLeftLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:toDayTimeTop];
        [self.co_todayDateLeftLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:ScreenWidth/2 - 100];
        [self.co_contentView addSubview:self.co_todayDateRightLabel];
        [self.co_todayDateRightLabel autoSetDimensionsToSize:CGSizeMake(130, 88)];
        [self.co_todayDateRightLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:toDayTimeTop];
        [self.co_todayDateRightLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:ScreenWidth/2 - 130];
        //end
        
        //添加标示时间操作的view
        [self.co_contentView addSubview:self.co_indicateDateView]; //260 44
        [self.co_indicateDateView autoSetDimensionsToSize:CGSizeMake(260, 44)];
        [self.co_indicateDateView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.co_indicateDateView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[MetaData isIphone4_4s] ? 70: 110];
        //end
        
        //添加日期选择
        [self createMinAndMaxDate];
        [self.co_contentView addSubview:self.calendarContentView]; //162 30
        [self.calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:[MetaData isIphone4_4s] ? 110: 160];
        [self.calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:30];
        [self.calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:30];
        [self.calendarContentView autoSetDimension:ALDimensionHeight toSize:250];
        //end
        
        //配置日期选择器基本参数
        // Create a min and max date for limit the calendar, optional
        //    [_calendarManager setMenuView:_calendarMenuView];
        [self.calendarManager setContentView:self.calendarContentView];
        [self.calendarManager setDate:_todayDate];
        //end
        
        //添加底部的两个按钮
        [self.co_contentView addSubview:self.co_bottomButtonView];
        [self.co_bottomButtonView autoSetDimension:ALDimensionHeight toSize:50];
        [self.co_bottomButtonView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.co_bottomButtonView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.co_bottomButtonView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        //end
    }
    return self;
}

#pragma mark - custom method

- (BOOL)isShowed
{
    return isShowed;
}

- (void)showWithSelectedDate:(NSDate *)selectedDate
{
    //更新标记时间label内容
    self.co_indicateDateLabel.text = [self indicateDateLabelTitleWithDate:selectedDate];
    [self updateTodayLabelContentWithDate:nil];
    _dateSelected = selectedDate;
    [self.calendarManager reload];
    //end
    
    MMTabbarController *tabbarVC = (MMTabbarController *)MMAppDelegate.nav.visibleViewController;
    GeneralSuperViewController *customVC = (GeneralSuperViewController *)[[tabbarVC viewControllers] firstObject];
    
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(customVC.customeNavBarView.frame.size, NO, 0.0);
    }
    //获取图像
    [customVC.customeNavBarView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.co_contentTopImageView.image = image;
    //end
    
    CGRect selfRect = self.frame;
    selfRect = [[UIApplication sharedApplication] keyWindow].bounds;
    selfRect.origin.y = 0;
    selfRect.size.height = CGRectGetHeight([[UIApplication sharedApplication] keyWindow].bounds);
    self.frame = selfRect;
    self.backgroundColor = [UIColor clearColor];
    [[[MMAppDelegate tabbarVC] view] addSubview:self];
    
    //内容试图
    self.co_contentView.frame = CGRectMake(0, - CGRectGetHeight(self.frame) + MMNavigationBarHeight, ScreenWidth, CGRectGetHeight(self.frame) - MMNavigationBarHeight);
    //end
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        CGRect selfRect = self.co_contentView.frame;
        selfRect.origin.y = MMNavigationBarHeight;
        self.co_contentView.frame = selfRect;
    } completion:^(BOOL finished) {
        isShowed = YES;
        if (selectedDate) {
            _dateSelected = selectedDate;
//            [self.calendarManager setDate:_todayDate];
//            [self.calendarManager reload];
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];

}

- (void)hide
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        CGRect selfRect = self.co_contentView.frame;
        selfRect.origin.y = - CGRectGetHeight(self.frame) + 64;
        self.co_contentView.frame = selfRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        isShowed = NO;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

/**
 *  格式化时间显示
 *
 */
- (NSString *)indicateDateLabelTitleWithDate:(NSDate *)date
{
    if (date == nil) {
        date = [NSDate dk_date];
    }
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy年 MM月";
    return [dateFmt stringFromDate:date];
}

/**
 *  更新顶部的时间显示
 *
 *  @param date 时间
 */
- (void)updateTodayLabelContentWithDate:(NSDate *)date
{
    if (date == nil) {
        date = [NSDate dk_date];
    }
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"dd";
    
    //左边的
    self.co_todayDateLeftLabel.text = [dateFmt stringFromDate:date];
    
    //右边的
    self.co_todayDateRightLabel.attributedText = [self todayDateRightLabelWithDate:date];
}

- (NSMutableAttributedString *)todayDateRightLabelWithDate:(NSDate *)date
{
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];

    NSString *firstString = nil;
    NSString *secondString = nil;
    
    dateFmt.dateFormat = @"MM";
    firstString = [dateFmt stringFromDate:date];
    
    dateFmt.dateFormat = @"yyyy";
    secondString = [dateFmt stringFromDate:date];
    
    NSString *allString = [NSString stringWithFormat:@"今天是\n%@月%@年",firstString, secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, allString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(4, firstString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(5 + firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, allString.length)];
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.paragraphSpacing = 4;
    parStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

#pragma mark - event

- (void)leftButtonTaped
{
    [self.calendarManager.contentView loadPreviousPageWithAnimation];
}

- (void)rightButtonTaped
{
    [self.calendarManager.contentView loadNextPageWithAnimation];
}

/**
 *  确定查看点击
 */
- (void)lookSelectDateTaped
{
    if (self.lookDate) {
        self.lookDate(_dateSelected);
    }
    [self hide];
}

/**
 *  查看今天点击
 */
- (void)lookTodayDateTaped
{
    if (self.lookDate) {
        self.lookDate([NSDate dk_date]);
    }
    [self hide];
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate dk_date];
    // Min date will be 2 month before today
    _minDate = [self.calendarManager.dateHelper addToDate:_todayDate months:-12];
    // Max date will be 2 month after today
    _maxDate = _todayDate;
    //[self.calendarManager.dateHelper addToDate:_todayDate months:2];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    return dateFormatter;
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:_todayDate isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor =  [UIColor colorWithRed:32/255.0 green:175/255.0 blue:230/255.0 alpha:1];
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:151/255.0 green:207/255.0 blue:51/255.0 alpha:1];
        dayView.dotView.backgroundColor = [UIColor clearColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor clearColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor clearColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    //如果选择了今天之后的日期，则返回
    if ([dayView.date compare:_todayDate] == NSOrderedDescending) {
        return;
    }
    //end
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //更新标记时间label内容
    self.co_indicateDateLabel.text = [self indicateDateLabelTitleWithDate:calendar.date];
    //end
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //更新标记时间label内容
    self.co_indicateDateLabel.text = [self indicateDateLabelTitleWithDate:calendar.date];
    //end
    
}

#pragma mark - getters and setters

- (UIView *)co_contentView
{
    if (_co_contentView == nil) {
        _co_contentView = [UIView new];
        _co_contentView.backgroundColor = [UIColor whiteColor];
    }
    return _co_contentView;
}

- (UILabel *)co_todayDateLeftLabel
{
    if (_co_todayDateLeftLabel == nil) {
        _co_todayDateLeftLabel = [UILabel new];
        _co_todayDateLeftLabel.backgroundColor = [UIColor clearColor];
        _co_todayDateLeftLabel.font = [UIFont systemFontOfSize:73];
        _co_todayDateLeftLabel.textAlignment = NSTextAlignmentRight;
    }
    return _co_todayDateLeftLabel;
}

- (UILabel *)co_todayDateRightLabel
{
    if (_co_todayDateRightLabel == nil) {
        _co_todayDateRightLabel = [UILabel new];
        _co_todayDateRightLabel.backgroundColor = [UIColor clearColor];
        _co_todayDateRightLabel.numberOfLines = 2;
    }
    return _co_todayDateRightLabel;
}

- (UIView *)co_indicateDateView
{
    if (_co_indicateDateView == nil) {
        _co_indicateDateView = [UIView new];
        
        //添加背景图片
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"date_sel_bg"]];
        [_co_indicateDateView addSubview:image];
        [image autoSetDimensionsToSize:CGSizeMake(240, 38)];
        [image autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [image autoAlignAxisToSuperviewAxis:ALAxisVertical];
        //end
        
        //左边回退的按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"date_sel_left"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(leftButtonTaped) forControlEvents:UIControlEventTouchUpInside];
        [_co_indicateDateView addSubview:button];
        [button autoSetDimension:ALDimensionWidth toSize:40];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [button autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [button autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        //end
        
        //右边回退的按钮
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"date_sel_right"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rightButtonTaped) forControlEvents:UIControlEventTouchUpInside];
        [_co_indicateDateView addSubview:button];
        [button autoSetDimension:ALDimensionWidth toSize:40];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:12];
        [button autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        self.co_indicateDateRightButton = button;
        //end
        
        //时间显示label
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20];
        [_co_indicateDateView addSubview:label];
        [label autoSetDimension:ALDimensionHeight toSize:30];
        [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:60];
        [label autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:60];
        [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        self.co_indicateDateLabel = label;
        //end
    }
    return _co_indicateDateView;
}

- (JTCalendarManager *)calendarManager
{
    if (_calendarManager == nil) {
        _calendarManager = [[JTCalendarManager alloc] init];
        _calendarManager.delegate = self;
    }
    return _calendarManager;
}

- (JTHorizontalCalendarView *)calendarContentView
{
    if (_calendarContentView == nil) {
        _calendarContentView = [[JTHorizontalCalendarView alloc] init];
    }
    return _calendarContentView;
}

- (UIView *)co_bottomButtonView
{
    if (_co_bottomButtonView == nil) {
        _co_bottomButtonView = [UIView new];
        
        //顶部分割线
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_co_bottomButtonView addSubview:lineView];
        [lineView autoSetDimension:ALDimensionHeight toSize:0.5];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        //end
        
        //确定查看按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"确定查看" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(lookSelectDateTaped) forControlEvents:UIControlEventTouchUpInside];
        [_co_bottomButtonView addSubview:button];
        [button autoSetDimension:ALDimensionWidth toSize:ScreenWidth/2];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [button autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [button autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        //end
        
        //查看今天按钮
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"回到今天" forState:UIControlStateNormal];
        [button setTitleColor:DKNavbackcolor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(lookTodayDateTaped) forControlEvents:UIControlEventTouchUpInside];
        [_co_bottomButtonView addSubview:button];
        [button autoSetDimension:ALDimensionWidth toSize:ScreenWidth/2];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [button autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [button autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        //end
        
        //按钮中间的分割线
        lineView = [UIView new];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_co_bottomButtonView addSubview:lineView];
        [lineView autoSetDimension:ALDimensionWidth toSize:0.5];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [lineView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [lineView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        //end
    }
    return _co_bottomButtonView;
}

@end
