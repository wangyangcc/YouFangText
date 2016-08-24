//
//  DKDataDetailViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/12/4.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKDataDetailViewController.h"
#import "DKUserImageView.h"
#import "UIImage+screenshot.h"
#import "FSLineChart.h"
#import "DKDataDetailScopeView.h"
#import "UIViewController+tapCanceGesture.h"
#import "MMSocialIconActionSheet.h"
#import "NSObject+dateFormat.h"
#import "DKDataDetailDayData.h"
#import "DKDataDetailTableViewCell.h"
#import "DKDataDetailTableSectionView.h"
#import "MMAppDelegateHelper.h"
#import "DKDataDetailHourData.h"
#import "DKHomeTableViewCell.h"
#import "NSString+extras.h"

@interface DKDataDetailViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIButton *scopeButton; /**<时间选择按钮 */
    UIImageView *scopeButtonIcon; /**<时间选择按钮icon */
    NSLayoutConstraint *scopeButtonIconTrailingConstraint; /**<时间选择按钮icon右边约束 */
    
    UIButton *frontDateButton;
    UIButton *nextDateButton;
}

@property (nonatomic, assign) BOOL dayDetailModel; /**< 查看天详情模式 */
@property (nonatomic, strong) NSDictionary *hourDatas; /** 天的小时数据 */
@property (nonatomic, strong) NSDate *dayDetailModelDate; /**< 天详情模式的查看日期 */

@property (nonatomic, strong) UIView *co_tableHeaderView;
@property (nonatomic, strong) UITableView *co_tableView;
@property (nonatomic, strong) FSLineChart *co_lineChart;
@property (nonatomic, strong) FSLineChart *co_lineChartTwo;

@property (nonatomic, strong) DKDataDetailScopeView *co_scopeView;
@property (nonatomic, strong) DKClientRequest *clientRequest;

@property (nonatomic, strong) NSDate *startDate; /**< 开始的日期 会根据查看模式和结束日期觉得 */

@property (nonatomic, strong) NSDate *endDate; /**< 结束的日期 */

@property (nonatomic, assign) DKDataDetailLookType lookType; /**< 查看的模式，按周，或者月查看 */

@property (nonatomic, strong) NSMutableArray *dayDatas; /** 天数数据 */

@property (nonatomic, strong) DKDataDetailViewModel *detailViewModel; /**< 用户刷新当前界面的数据封装 */

@end

@implementation DKDataDetailViewController

- (id)initDayDetailModelWithHourDatas:(NSDictionary *)hourDatas dayDate:(NSDate *)dayDate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dayDetailModel = YES;
        self.hourDatas = hourDatas;
        self.dayDetailModelDate = [dayDate copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self updateViewStyle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.customeNavBarView.m_navTitleLabel.text = self.detailTypeName?:@"";
    if (self.dayDetailModel) {
        [self handleHourDatas];
    }
    else {
        if ([self.dayDatas count] == 0) {
            [self beginRequest];
        }
    }
//    MMAppDelegate.nav.isSlider = NO;
}

#pragma mark - custom method

- (void)addTapCanceGesture
{
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        __strong DKDataDetailViewController *vc = weakSelf;
        //如果正在动画中，则返回
        if ([vc.co_scopeView isAnimation]) {
            return;
        }
        //end
        if ([vc->scopeButton isSelected]) {
            vc->scopeButton.selected = NO;
            [vc updateScopeButtonIconState:YES];
        }
    }];
}

- (void)updateViewStyle
{
    //设置导航条
//    self.customeNavBarView.m_navLeftBtn.hidden = YES;
//    CGRect leftButtonRect = self.customeNavBarView.m_navLeftBtn.frame;
//    leftButtonRect.size.width = 34;
//    self.customeNavBarView.m_navLeftBtn.frame = leftButtonRect;
//    DKUserImageView *userImage = [[DKUserImageView alloc] init];
//    [self.customeNavBarView addSubview:userImage];
//    [userImage autoSetDimensionsToSize:CGSizeMake(50, 44)];
//    [userImage autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:CGRectGetWidth(self.customeNavBarView.m_navLeftBtn.frame)];
//    [userImage autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    if (MMAppDelegate.isShowShare) {
        self.customeNavBarView.m_navRightBtnImage = [UIImage imageNamed:@"nav_share"];
    }
    //end
    
    //添加表头
    [self.view addSubview:self.co_tableHeaderView];
    [self.co_tableHeaderView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MMNavigationBarHeight];
    [self.co_tableHeaderView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_tableHeaderView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_tableHeaderView autoSetDimension:ALDimensionHeight toSize:([MetaData valueForDeviceCun3_5:204 cun4:204 cun4_7:204 cun5_5:204*ScreenWidth/375] + (self.dayDetailModel ? 0 : 30))];
    //end
    
    //添加表格
    [self.view addSubview:self.co_tableView];
    [self.co_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.co_tableHeaderView];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    //end
    
    self.endDate = [NSObject toadyFormatDate];
    
    if (self.dayDetailModel) {
        self.lookType = -1;
    }
}

- (void)navRightBtnTapped
{
    if (MMAppDelegate.isShowShare) {
        [self performSelector:@selector(screenshot) withObject:nil afterDelay:0.2];
    }
}

- (void)screenshot
{
    UIImage *screenshot = [UIImage screenshotForView:[[UIApplication sharedApplication] keyWindow]];
    
    MMSocialIconActionSheet *sheet = [[MMSocialIconActionSheet alloc] initWithItems:MMAppDelegate.appModel.snsPlatformNames delegate:self shareText:nil shareImage:screenshot];
    [sheet show];
}

//范围选择
- (void)scopeButtonTaped
{
    //如果正在动画中，则返回
    if ([self.co_scopeView isAnimation]) {
        return;
    }
    //end
    if ([scopeButton isSelected]) {
        [self updateScopeButtonIconState:YES];
    }
    else {
        [self updateScopeButtonIconState:NO];
    }
    scopeButton.selected = ![scopeButton isSelected];
    
}

/**
 *  更新范围选择 icon 的状态
 */
- (void)updateScopeButtonIconState:(BOOL)isHide
{
    if (self.co_scopeView.superview == nil) {
        //添加性别选择的试图
        [self.view addSubview:self.co_scopeView];
        
        __weak typeof(self) weakSelf = self;
        [self.co_scopeView setOnButtonTouchUpInside:^(DKDataDetailScopeView *scopeView, NSInteger buttonIndex, NSString *buttonString) {
            __strong DKDataDetailViewController *vc = weakSelf;

            //如果正在动画中，则返回
            if ([scopeView isAnimation]) {
                return;
            }
            weakSelf.lookType = buttonIndex;
            //end
            [vc->scopeButton setTitle:buttonString forState:UIControlStateNormal];
            vc.endDate = [NSObject toadyFormatDate];
            vc->nextDateButton.enabled = NO;
            vc->scopeButton.selected = NO;
            [vc updateScopeButtonIconState:YES];
            [vc beginRequest];
        }];
        self.co_scopeView.hidden = YES;
        [self.co_scopeView autoSetDimensionsToSize:CGSizeMake(kDKDataDetailScopeViewContentWidth, kDKDataDetailScopeViewContentHeight)];
        [self.co_scopeView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.co_scopeView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scopeButton];
        //end
    }
    if (isHide) {
        [self removeTapCanceGesture];
        __weak typeof(self) weakSelf = self;
        [self.co_scopeView hideWithCompletion:^(BOOL finished) {
            weakSelf.co_scopeView.hidden = YES;
        }];
        
        [scopeButtonIcon.layer removeAllAnimations];
        
        CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim1.fromValue = [NSNumber numberWithFloat:((180*M_PI)/180)];
        anim1.toValue = [NSNumber numberWithFloat:0];
        anim1.duration = .35;
        anim1.removedOnCompletion = YES;
        [scopeButtonIcon.layer addAnimation:anim1 forKey:@"transform"];
    }
    else {
        self.co_scopeView.hidden = NO;
        [self.co_scopeView show];
        [self addTapCanceGesture];
        
        [scopeButtonIcon.layer removeAllAnimations];
        
        CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim1.fromValue = [NSNumber numberWithFloat:0];
        anim1.toValue = [NSNumber numberWithFloat:((180*M_PI)/180)];
        anim1.duration = .35;
        anim1.removedOnCompletion = NO;
        anim1.fillMode = kCAFillModeForwards;
        [scopeButtonIcon.layer addAnimation:anim1 forKey:@"transform"];
    }
}

/**
 *  左边的范围按钮点击
 */
- (void)leftScopeButtonTaped
{
    nextDateButton.enabled = YES;
    if (self.lookType == DKDataDetailLookTypeWeek) {
        self.endDate = [NSObject getWeekEndFormatDateWithDate:self.endDate isLast:YES];
    }
    else {
        self.endDate = [NSObject getMonthEndFormatDateWithDate:self.endDate isLast:YES];
    }
    
    [self updateScopeButtonTitle];
    [self beginRequest];
}

/**
 *  右边的范围按钮点击
 */
- (void)rightScopeButtonTaped
{
    if (self.lookType == DKDataDetailLookTypeWeek) {
        self.endDate = [NSObject getWeekEndFormatDateWithDate:self.endDate isLast:NO];
    }
    else {
        self.endDate = [NSObject getMonthEndFormatDateWithDate:self.endDate isLast:NO];
    }
    
    //判断是否到了尽头
    if (self.lookType == DKDataDetailLookTypeWeek) {
        NSDate *nextDate = [NSObject thisWeekEndFormatDate];
        if ([nextDate compare:self.endDate] == NSOrderedSame) {
            nextDateButton.enabled = NO;
        }
    }
    else {
        if ([NSObject isSameMonthWithOneDate:self.endDate otherDate:[NSDate dk_date]]) {
            nextDateButton.enabled = NO;
        }
    }
    //end
    [self updateScopeButtonTitle];
    [self beginRequest];
}

/**
 *  更新选择按钮内容
 */
- (void)updateScopeButtonTitle
{
    NSString *newTitle = (self.lookType == DKDataDetailLookTypeWeek ? @"过去一周" : @"过于一月");
    if ([nextDateButton isEnabled]) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        if (self.lookType == DKDataDetailLookTypeWeek) {
            [formatter setDateFormat:@"M月d日"];
            newTitle = [NSString stringWithFormat:@"%@-%@",[formatter stringFromDate:self.startDate],[formatter stringFromDate:self.endDate]];
        }
        else {
            [formatter setDateFormat:@"yy年M月份"];
            newTitle = [formatter stringFromDate:self.endDate];
        }
    }
    [scopeButton setTitle:newTitle forState:UIControlStateNormal];
    
    //更新icon右边约束
    if (self.lookType == DKDataDetailLookTypeWeek) {
        scopeButtonIconTrailingConstraint.constant = 0;
    }
    else {
        scopeButtonIconTrailingConstraint.constant = -20;
    }
    //end
}

- (void)beginRequest
{
    [SVProgressHUD show];
    [self.clientRequest serialDataWithSerialNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber] startDate:[NSObject requestParameterFormatDateWithDate:self.startDate] endDate:[NSObject requestParameterFormatDateWithDate:self.endDate]];
}

- (BOOL)isDisplayStarWithValue:(id)valueNumber
{
    if (self.dayDetailModel) {
        return NO;
    }
    if (![self.detailTypeParameter isEqualToString:@"walk"] && ![self.detailTypeParameter isEqualToString:@"allSleep"]) {
        return NO;
    }
    if (!valueNumber) {
        valueNumber = @"0";
    }
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
    NSArray *arrays = [deviceInfo.target componentsSeparatedByString:@"#"];
    NSString *firstValue = [arrays firstObject]?:@"0";
    NSString *lastValue = [arrays lastObject]?:@"0";
    if ([self.detailTypeParameter isEqualToString:@"walk"]) {
        if ([valueNumber floatValue] - [firstValue floatValue] > 0.000001) {
            return YES;
        }
    }
    else if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
        if ([valueNumber floatValue] - [lastValue floatValue]*60 > 0.000001) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - update date and view

/**
 *  处理天数数据，进行封装，得到用户界面刷新的数据
 */
- (void)handleDayDatas
{
    self.detailViewModel = [DKDataDetailViewModel new];
    self.detailViewModel.lookType = self.lookType;
    self.detailViewModel.tableViewData = [NSMutableArray array];
    self.detailViewModel.tableViewHeaderData = [NSMutableArray array];
    
    NSArray *chartIndexDates = nil;
    if (self.lookType == DKDataDetailLookTypeWeek) {
        self.detailViewModel.chartIndex = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
        
        //得到当前的数值列表
        [self.detailViewModel.tableViewHeaderData addObject:![nextDateButton isEnabled]?@"当前":@"详细"];
        [self.detailViewModel.tableViewData addObject:[NSObject getWeekEveryDaysWithEndDate:self.endDate]];
        chartIndexDates = [self.detailViewModel.tableViewData firstObject];
        //end
        
        NSDate *thisWeekFirstDate = [NSObject getWeekFirstDateWithWeekEndDate:self.endDate];
        NSString *thisWeekTitle = [NSString stringWithFormat:@"本周(%@-%@)",[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:thisWeekFirstDate],[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:self.endDate]];
        [self.detailViewModel.tableViewHeaderData addObject:thisWeekTitle];

        //end
    }
    else {
        NSMutableArray *chartIndexArray = [NSMutableArray arrayWithArray:@[@"1",@"5",@"9",@"13",@"17",@"21",@"25"]];
        //得到最后一天的day
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"dd"];
        NSString *lastDateStr = [formatter stringFromDate:[NSObject getMonthLastDateWithMonthOneDate:self.endDate]];
        [chartIndexArray addObject:lastDateStr];
        //end
        self.detailViewModel.chartIndex = chartIndexArray;
        chartIndexDates = [self.detailViewModel getChartIndexDatesWithEndDate:self.endDate chartIndex:chartIndexArray];
        
        //得到当前的数值列表
        if ([nextDateButton isEnabled]) {
            NSDate *lastWeekFirstDate = [NSObject getWeekFirstDateWithWeekEndDate:self.endDate];
            NSString *lastWeekTitle = [NSString stringWithFormat:@"%@-%@",[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:lastWeekFirstDate],[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:self.endDate]];
            [self.detailViewModel.tableViewHeaderData addObject:lastWeekTitle];
        }
        else {
            [self.detailViewModel.tableViewHeaderData addObject:@"本周"];
        }
        [self.detailViewModel.tableViewData addObject:[NSObject getWeekEveryDaysWithEndDate:self.endDate]];
        //end
        
        //判断这个月，除了endDate外，还有几周
        BOOL isSameMonth = YES;
        NSDate *whileEndDate = [self.endDate copy];
        while (isSameMonth) {
            NSDate *lastWeekDate = [NSObject getWeekEndFormatDateWithDate:whileEndDate isLast:YES];
            isSameMonth = [NSObject isSameMonthWithOneDate:lastWeekDate otherDate:whileEndDate];
            whileEndDate = lastWeekDate;
            if (isSameMonth) {
                NSDate *lastWeekFirstDate = [NSObject getWeekFirstDateWithWeekEndDate:lastWeekDate];
                isSameMonth = [NSObject isSameMonthWithOneDate:lastWeekDate otherDate:lastWeekFirstDate];
                NSMutableArray *lastWeekDays = [NSObject getWeekEveryDaysWithEndDate:lastWeekDate];
                if (isSameMonth == NO) {
                    NSInteger index;
                    NSDate *lastWeekFirstDateTmp = nil;
                    for (index = [lastWeekDays count] - 1; index >= 0; index --) {
                        NSDate *lastWeekDayOne = lastWeekDays[index];
                        if ([NSObject isSameMonthWithOneDate:lastWeekDayOne otherDate:lastWeekDate]) {
                            if (lastWeekFirstDateTmp == nil) {
                                lastWeekFirstDateTmp = lastWeekDate;
                                lastWeekFirstDate = lastWeekDayOne;
                            }
                        }
                        else {
                            [lastWeekDays removeObjectAtIndex:index];
                            index = [lastWeekDays count];
                        }
                    }
                }
                NSString *lastWeekTitle = [NSString stringWithFormat:@"%@-%@",[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:lastWeekFirstDate],[DKDataDetailTableViewCell getMonthDayFormatDateWithDate:lastWeekDate]];
                [self.detailViewModel.tableViewHeaderData addObject:lastWeekTitle];
                [self.detailViewModel.tableViewData addObject:lastWeekDays];
            }
        }
        //end
        
        [formatter setDateFormat:@"M"];
        NSString *thisMontyDateStr = [NSString stringWithFormat:@"本月(%@月份)",[formatter stringFromDate:self.endDate]];
        [self.detailViewModel.tableViewHeaderData addObject:thisMontyDateStr];
        //end
    }
    
    [self handleStatisticsData];

    [self handleLineChartWithDates:chartIndexDates];
    
    [self.co_tableView reloadData];
    [SVProgressHUD dismiss];
}

/**
 *  处理天的小时数据，进行封装，得到用户界面刷新的数据
 */
- (void)handleHourDatas
{
    //计算所有数据源
    self.dayDatas = [NSMutableArray array];
    for (NSString *hourDate in [self.hourDatas allKeys]) {
        NSDictionary *hourData = self.hourDatas[hourDate];
        NSError *error = nil;
        DKDataDetailHourData *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKDataDetailHourData") fromJSONDictionary:hourData error:&error];
        model.detailTypeParameter = self.detailTypeParameter;
        [self.dayDatas addObject:model];
    }
    //end
    
    self.detailViewModel = [DKDataDetailViewModel new];
    self.detailViewModel.tableViewData = [NSMutableArray array];
    self.detailViewModel.tableViewHeaderData = [NSMutableArray array];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"yyyyMMddHH"];
    
    //图表需要的数据
    self.detailViewModel.chartIndex = @[@"0",@"4",@"8",@"12",@"16",@"20",@"23"];
    NSMutableArray *chartIndexDates = [NSMutableArray array];
    NSArray *chartIndexT = @[@"00",@"04",@"08",@"12",@"16",@"20",@"23"];
    for (NSInteger index = 0; index < [chartIndexT count]; index ++) {
        NSString *hourDateStr = [NSString stringWithFormat:@"%@%@",[NSObject requestParameterFormatDateWithDate:self.dayDetailModelDate],chartIndexT[index]];
        [chartIndexDates addObject:[formatter dateFromString:hourDateStr]];
    }
    //end

    //得到当前的数值列表
    [self.detailViewModel.tableViewHeaderData addObject:@"详细"];
    NSMutableArray *hourDateArray = [NSMutableArray array];
    for (int index = 0; index < 24; index ++) {
        NSString *hourDateStr = nil;
        if (index < 10) {
            hourDateStr = [NSString stringWithFormat:@"%@0%d",[NSObject requestParameterFormatDateWithDate:self.dayDetailModelDate],index];
        }
        else {
            hourDateStr = [NSString stringWithFormat:@"%@%d",[NSObject requestParameterFormatDateWithDate:self.dayDetailModelDate],index];
        }
        [hourDateArray addObject:[formatter dateFromString:hourDateStr]];
    }
    [self.detailViewModel.tableViewData addObject:hourDateArray];
    //end
    
    [formatter setDateFormat:@"MM月dd日"];
    NSString *thisDayDateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:[hourDateArray firstObject]]];
    [self.detailViewModel.tableViewHeaderData addObject:thisDayDateStr];

    //end
    
    [self handleStatisticsData];
    
    [self.co_tableView reloadData];
    
    [self handleLineChartWithDates:chartIndexDates];
    //end
    [SVProgressHUD dismiss];
}

//绑定统计（最大，最小，平均）的数据
- (void)handleStatisticsData
{
    NSMutableArray *typeValueArray = [NSMutableArray array];
    NSMutableArray *typeValueArrayT = nil;
    if (self.isDoubleChart) {
        typeValueArrayT = [NSMutableArray array];
    }
    
    //取出需要的值
    [self.dayDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DKDataDetailDayData *model = obj;
        if (self.isDoubleChart) {
            NSArray *parameters = [DKHomeTableViewCell doubleChartTypeParametersWithTypeParameter:self.detailTypeParameter];
            
            if ([self.detailTypeParameter isEqualToString:@"blood"]) {
                [typeValueArray addObject:model.avgLblood];
                [typeValueArrayT addObject:model.avgHblood];
            }
            else if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
                [typeValueArray addObject:model.detailTypeValue];
                NSString *sleepTimeT = [NSString getSleepHourTimeWithMinuteTimeT:[model.dayData objectForKey:[parameters lastObject]]];
                [typeValueArrayT addObject:sleepTimeT];
            }
        }
        else {
            
            [typeValueArray addObject:model.detailTypeValue];
        }
    }];
    //end

    //补齐数据
//    //周详情
//    if (self.lookType == DKDataDetailLookTypeWeek) {
//        
//        //补齐7天
//        if ([typeValueArray count] != 7) {
//            for (NSInteger index = [typeValueArray count]; index < 7; index ++) {
//                [typeValueArray addObject:@"0"];
//            }
//        }
//        if (typeValueArrayT && [typeValueArrayT count] != 7) {
//            for (NSInteger index = [typeValueArrayT count]; index < 7; index ++) {
//                [typeValueArrayT addObject:@"0"];
//            }
//        }
//        //end
//    }
//    //月详情
//    else if (self.lookType == DKDataDetailLookTypeMouth) {
//        //得到最后一天的day
//        NSDateFormatter *formatter = [NSDateFormatter new];
//        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
//        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//        [formatter setDateFormat:@"dd"];
//        NSString *lastDateStr = [formatter stringFromDate:self.endDate];
//        
//        //补齐数据
//        if ([typeValueArray count] != [lastDateStr integerValue]) {
//            for (NSInteger index = [typeValueArray count]; index < [lastDateStr integerValue]; index ++) {
//                [typeValueArray addObject:@"0"];
//            }
//        }
//        if ([typeValueArrayT count] != [lastDateStr integerValue]) {
//            for (NSInteger index = [typeValueArrayT count]; index < [lastDateStr integerValue]; index ++) {
//                [typeValueArrayT addObject:@"0"];
//            }
//        }
//        //end
//    }
//    //天详情
//    else {
//        //补齐数据
//        if ([typeValueArray count] != 24) {
//            for (NSInteger index = [typeValueArray count]; index < 24; index ++) {
//                [typeValueArray addObject:@"0"];
//            }
//        }
//        if ([typeValueArrayT count] != 24) {
//            for (NSInteger index = [typeValueArrayT count]; index < 24; index ++) {
//                [typeValueArrayT addObject:@"0"];
//            }
//        }
//        //end
//    }
    
    //移除空的元素
    [typeValueArray removeObject:@"0"];
    [typeValueArray removeObject:@"0.0"];
    [typeValueArray removeObject:@(0)];
    [typeValueArray removeObject:@(0.0)];
    
    //计算平均数据
    float avgValue = [[typeValueArray valueForKeyPath:@"@sum.floatValue"] floatValue]/[typeValueArray count];
    //平均
    NSString *aveTitle = [typeValueArray count] > 0 ? [NSString stringWithFormat:@"%.1f",avgValue] : @"0";
    //最大
    NSString *maxTitle = [typeValueArray count] > 0 ? [NSString stringWithFormat:@"%@",[typeValueArray valueForKeyPath:@"@max.floatValue"]] : @"0";
    //最小
    NSString *minTitle = [typeValueArray count] > 0 ? [NSString stringWithFormat:@"%@",[typeValueArray valueForKeyPath:@"@min.floatValue"]] : @"0";
    aveTitle = [DKDataDetailDayData aveFormatNumber:aveTitle detailTypeParameter:self.detailTypeParameter];
    
    if (self.isDoubleChart) {
        //移除空的元素
        [typeValueArrayT removeObject:@"0"];
        [typeValueArrayT removeObject:@"0.0"];
        [typeValueArrayT removeObject:@(0)];
        [typeValueArrayT removeObject:@(0.0)];
        
        float avgValueT = [[typeValueArrayT valueForKeyPath:@"@sum.floatValue"] floatValue]/[typeValueArrayT count];
        NSString *aveTitleT = [typeValueArrayT count] > 0 ? [NSString stringWithFormat:@"%.1f",avgValueT] : @"0";
        aveTitleT = [DKDataDetailDayData aveFormatNumber:aveTitleT detailTypeParameter:self.detailTypeParameter];
        aveTitle = [aveTitle stringByAppendingFormat:@"/%@",aveTitleT];
        maxTitle = [maxTitle stringByAppendingFormat:@"/%@",[typeValueArrayT count] > 0 ? [typeValueArrayT valueForKeyPath:@"@max.floatValue"] : @"0"];
        minTitle = [minTitle stringByAppendingFormat:@"/%@",[typeValueArrayT count] > 0 ? [typeValueArrayT valueForKeyPath:@"@min.floatValue"] : @"0"];
    }
    
    NSMutableArray *statistics = [NSMutableArray array];
    //单项去掉平均数
    if (self.dayDetailModel == NO) {
        [statistics addObject:@{@"平均": aveTitle}];
    }
    [statistics addObject:@{@"最高": maxTitle}];
    [statistics addObject:@{@"最低": minTitle}];
    [self.detailViewModel.tableViewData addObject:statistics];
}

//添加图表
- (void)handleLineChartWithDates:(NSArray *)chartIndexDates
{
    NSMutableArray *chartData = [NSMutableArray array];
    NSMutableArray *chartDataT = nil;
    if (self.isDoubleChart) {
        chartDataT = [NSMutableArray array];
    }
    //如果是查看周视图，则倒叙时间
    if (self.lookType == DKDataDetailLookTypeWeek) {
        chartIndexDates = [[chartIndexDates reverseObjectEnumerator] allObjects];
    }
    //获取数据
    for (NSInteger index = 0; index < [chartIndexDates count]; index ++) {
        NSString *dayDateString = nil;
        if (self.dayDetailModel) {
            dayDateString = [NSObject requestParameterFormatHourDateWithDate:[chartIndexDates objectAtIndex:index]];
        }
        else {
            dayDateString = [NSObject requestParameterFormatDateWithDate:[chartIndexDates objectAtIndex:index]];
        }
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"dayDate", @([dayDateString integerValue])];
        NSArray *results = [self.dayDatas filteredArrayUsingPredicate:predicateID];
        if (results && [results count] >= 1) {
            DKDataDetailDayData *value = [results firstObject];
            if (self.isDoubleChart) {
                NSArray *parameters = [DKHomeTableViewCell doubleChartTypeParametersWithTypeParameter:self.detailTypeParameter];
                //测试数据
//                int x = (arc4random() % 100) + 150;
//                [chartData addObject:[NSString stringWithFormat:@"%d",x]];
//                int y = (arc4random() % 301) + 300;
//                [chartDataT addObject:[NSString stringWithFormat:@"%d",y]];
                
                if ([self.detailTypeParameter isEqualToString:@"blood"]) {
                    [chartData addObject:[NSString stringWithFormat:@"%.1f",[value.avgLblood floatValue]]];
                    [chartDataT addObject:[NSString stringWithFormat:@"%.1f",[value.avgHblood floatValue]]];
                }
                else if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
                    NSString *sleepTime = [NSString stringWithFormat:@"%.1f",[[value.dayData objectForKey:[parameters lastObject]] floatValue]];
                    [chartData addObject:sleepTime];
                    [chartDataT addObject:value.detailTypeValue];
                }
            }
            else {
                [chartData addObject:value.detailTypeValue];
            }
        }
        else {
            [chartData addObject:@"0"];
            if (self.isDoubleChart) {
                [chartDataT addObject:@"0"];
            }
        }
    }
    //end
    //数据补齐
    if ([chartData count] != [self.detailViewModel.chartIndex count]) {
        for (NSInteger index = [chartData count]; index < [self.detailViewModel.chartIndex count]; index ++) {
            [chartData addObject:@"0"];
        }
    }
    if (chartDataT && [chartDataT count] != [self.detailViewModel.chartIndex count]) {
        for (NSInteger index = [chartDataT count]; index < [self.detailViewModel.chartIndex count]; index ++) {
            [chartDataT addObject:@"0"];
        }
    }
    //end
    
    //设置图表内容
    __weak typeof(self) weakSelf = self;
    _co_lineChart.verticalGridStep = 1;
    _co_lineChart.isDisplaySleep = [self.detailTypeParameter isEqualToString:@"allSleep"];
    _co_lineChart.horizontalGridStep = (int)[self.detailViewModel.chartIndex count];
    _co_lineChart.labelForIndex = ^(NSUInteger item) {
        return weakSelf.detailViewModel.chartIndex[item];
    };
    _co_lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.f", value];
    };
    
    [_co_lineChart clearChartScaleplate];
    [_co_lineChart clearChartData];
    [_co_lineChart setChartData:chartData];
    //end
    
    //设置第二个图标
    if (self.isDoubleChart) {
        if (_co_lineChartTwo == nil) {
            //表格
            self.co_lineChartTwo = [[FSLineChart alloc] initWithFrame:CGRectMake(0, self.dayDetailModel?-20:0, ScreenWidth, [MetaData valueForDeviceCun3_5:204 cun4:204 cun4_7:204 cun5_5:204*ScreenWidth/375])];//204
            self.co_lineChartTwo.backgroundColor = [UIColor clearColor];
            [_co_tableHeaderView addSubview:self.co_lineChartTwo];
            //end
            
            // Creating the line chart
            _co_lineChartTwo.isDisplaySleep = [self.detailTypeParameter isEqualToString:@"allSleep"];
            _co_lineChartTwo.indexLabelTextColor = [UIColor clearColor];
            _co_lineChartTwo.displayDataPoint = YES;
            _co_lineChartTwo.fillColor = [UIColor colorWithWhite:1 alpha:0.25];
            _co_lineChartTwo.lineWidth = 0.0f;
            _co_lineChartTwo.bezierSmoothing = NO;//不往下延伸
            _co_lineChartTwo.dataPointBackgroundColor = [UIColor clearColor];
            _co_lineChartTwo.dataPointColor = [UIColor whiteColor];
            _co_lineChartTwo.axisColor = [UIColor clearColor];
            _co_lineChartTwo.indexLabelBackgroundColor = [UIColor clearColor];
            _co_lineChartTwo.valueLabelTextColor = [UIColor whiteColor];
            _co_lineChartTwo.valueLabelBackgroundColor = [UIColor clearColor];
            _co_lineChartTwo.innerGridColor = [UIColor whiteColor];
            //end
            
            [_co_tableHeaderView bringSubviewToFront:frontDateButton];
            [_co_tableHeaderView bringSubviewToFront:nextDateButton];
            [_co_tableHeaderView bringSubviewToFront:scopeButton];
        }
        
        _co_lineChartTwo.verticalGridStep = 1;
        _co_lineChartTwo.horizontalGridStep = (int)[self.detailViewModel.chartIndex count];
        _co_lineChartTwo.labelForIndex = ^(NSUInteger item) {
            return weakSelf.detailViewModel.chartIndex[item];
        };
        _co_lineChartTwo.labelForValue = ^(CGFloat value) {
            return [NSString stringWithFormat:@"%.f", value];
        };
        
        [_co_lineChartTwo clearChartScaleplate];
        [_co_lineChartTwo clearChartData];
        [_co_lineChartTwo setChartData:chartDataT];
        //end
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.detailViewModel.tableViewData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= [self.detailViewModel.tableViewData count]) {
        return 0;
    }
    NSArray *sectionArray = [self.detailViewModel.tableViewData objectAtIndex:section];
    return [sectionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 41;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DKDataDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DKDataDetailTableViewCell"];
    
    NSMutableArray *sectionArray = [self.detailViewModel.tableViewData objectAtIndex:indexPath.section];
    //判断是不是最后一个区
    if (indexPath.section == [self.detailViewModel.tableViewData count] - 1) {
        NSDictionary *rowDic = [sectionArray objectAtIndex:indexPath.row];
        NSString *contentValue = nil;
        if (self.isDoubleChart){
            contentValue = rowDic[[[rowDic allKeys] lastObject]];
        }
        else {
            contentValue = rowDic[[[rowDic allKeys] firstObject]];
            contentValue = [DKDataDetailDayData aveFormatNumber:contentValue detailTypeParameter:self.detailTypeParameter];
        }
        NSString *titleType = nil;
        NSArray *titleArrays = [contentValue componentsSeparatedByString:@"/"];
        if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
            
            contentValue = [NSString stringWithFormat:@"%ld",[[titleArrays firstObject] integerValue]/60];
            titleType = [NSString stringWithFormat:@"时%ld分(深睡%ld时%ld分)",[[titleArrays firstObject] integerValue]%60,[[titleArrays lastObject] integerValue]/60,[[titleArrays lastObject] integerValue]%60];
        }
        else {
            titleType = [self.detailUnitName copy];
        }
        [cell updateWithTitle:[[rowDic allKeys] firstObject] content:contentValue titleType:titleType displayStar:NO];
    }
    else {
        NSDate *dayDate = [sectionArray objectAtIndex:indexPath.row];
        NSString *dayDateString = nil;
        if (self.dayDetailModel) {
            dayDateString = [NSObject requestParameterFormatHourDateWithDate:dayDate];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            dayDateString = [NSObject requestParameterFormatDateWithDate:dayDate];
        }
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"dayDate", @([dayDateString integerValue])];
        NSArray *results = [self.dayDatas filteredArrayUsingPredicate:predicateID];
        
        NSString *titleType = [self.detailUnitName copy];
        if (results && [results count] >= 1) {
            DKDataDetailDayData *value = [results firstObject];
            NSString *contentStr = value.detailTypeValue;
            
            if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
                NSInteger sleepMinuteTime = value.dayData[@"totalSleep"] ? [value.dayData[@"totalSleep"] integerValue] : 0;
                contentStr = [NSString stringWithFormat:@"%ld",sleepMinuteTime/60];
                titleType = [NSString stringWithFormat:@"时%ld分(深睡%@)",sleepMinuteTime%60,[NSString getSleepHourTimeWithMinuteTimeT:value.dayData[@"sleep"]]];
            }
            [cell updateWithTitle:[DKDataDetailTableViewCell getCellDisplayTitleDateWithDate:dayDate lookType:self.lookType] content:contentStr titleType:titleType displayStar:[self isDisplayStarWithValue:value.detailTypeValue]];
        }
        else {
            if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
                titleType = [NSString stringWithFormat:@"时0分(深睡0时0分)"];
            }
            NSString *contentTit = @"0";
            if ([self.detailTypeParameter isEqualToString:@"blood"]) {
                contentTit = @"0/0";
            }
            [cell updateWithTitle:[DKDataDetailTableViewCell getCellDisplayTitleDateWithDate:dayDate lookType:self.lookType] content:contentTit titleType:titleType displayStar:NO];
        }
    }
    //end
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dayDetailModel) {
        return;
    }
    //判断是不是最后一个区
    if (indexPath.section != [self.detailViewModel.tableViewData count] - 1) {
//        
//        //睡眠不可查看小时详情
//        if ([self.detailTypeParameter isEqualToString:@"allSleep"]) {
//            return;
//        }
//        //end
        
        NSMutableArray *sectionArray = [self.detailViewModel.tableViewData objectAtIndex:indexPath.section];
        
        NSDate *dayDate = [sectionArray objectAtIndex:indexPath.row];
        NSString *dayDateString = [NSObject requestParameterFormatDateWithDate:dayDate];
        NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"dayDate", @([dayDateString integerValue])];
        NSArray *results = [self.dayDatas filteredArrayUsingPredicate:predicateID];
        DKDataDetailDayData *value = [DKDataDetailDayData new];
        if (results && [results count] >= 1) {
            value = [results firstObject];
        }
        value.detailTypeParameter = self.detailTypeParameter;
        DKDataDetailViewController *vc = [[DKDataDetailViewController alloc] initDayDetailModelWithHourDatas:value.dayHourDatas dayDate:dayDate];
        vc.detailTypeParameter = self.detailTypeParameter;
        vc.detailTypeName = self.detailTypeName;
        vc.detailUnitName = self.detailUnitName;
        vc.isDoubleChart = self.isDoubleChart;
        [MMAppDelegate.nav pushViewController:vc];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DKDataDetailTableSectionView *sectionView = (DKDataDetailTableSectionView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DKDataDetailTableSectionView"];
    sectionView.contentView.backgroundColor = MMRGBColor(218, 197, 63);
    [sectionView updateWithTitle:[self.detailViewModel.tableViewHeaderData objectAtIndex:section]];
    return sectionView;
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    //格式化数据
    NSDictionary *resultDic = clientRequest.responseObject;
    if ([resultDic[@"isSuccess"] boolValue] == NO) {
        [SVProgressHUD showErrorWithStatus:[DKClientRequest errorCodeDic][resultDic[@"errorCode"]]];
        return;
    }
    
    //获取每天的数据集合
    NSError *error = nil;
    NSDictionary *dayDatasDic = resultDic[@"dayDatas"];
    self.dayDatas = [NSMutableArray array];
    for (NSString *dayDate in [dayDatasDic allKeys]) {
        NSDictionary *dayData = dayDatasDic[dayDate];
        DKDataDetailDayData *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKDataDetailDayData") fromJSONDictionary:dayData error:&error];
        model.detailTypeParameter = self.detailTypeParameter;
        [self.dayDatas addObject:model];
    }
    //end
    
    [self handleDayDatas];
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
}

#pragma mark - getters and setters

- (UIView *)co_tableHeaderView
{
    if (_co_tableHeaderView == nil) {
        _co_tableHeaderView = [UIView new];
        
        //背景图
        UIImageView *blImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhsj-bg"]];
        [_co_tableHeaderView addSubview:blImageView];
        [blImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        //end
        
        //表格
        self.co_lineChart = [[FSLineChart alloc] initWithFrame:CGRectMake(0, self.dayDetailModel?-20:0, ScreenWidth, [MetaData valueForDeviceCun3_5:204 cun4:204 cun4_7:204 cun5_5:204*ScreenWidth/375])];//204
        self.co_lineChart.backgroundColor = [UIColor clearColor];
        [_co_tableHeaderView addSubview:self.co_lineChart];
        //end
        
        // Creating the line chart
        _co_lineChart.indexLabelTextColor = [UIColor whiteColor];
        _co_lineChart.displayDataPoint = YES;
        _co_lineChart.fillColor = [UIColor colorWithWhite:1 alpha:0.25];
        _co_lineChart.lineWidth = 0.0f;
        _co_lineChart.bezierSmoothing = NO;//不往下延伸
        _co_lineChart.dataPointBackgroundColor = [UIColor clearColor];
        _co_lineChart.dataPointColor = [UIColor whiteColor];
        _co_lineChart.axisColor = [UIColor clearColor];
        _co_lineChart.indexLabelBackgroundColor = [UIColor clearColor];
        _co_lineChart.valueLabelTextColor = [UIColor whiteColor];
        _co_lineChart.valueLabelBackgroundColor = [UIColor clearColor];
        _co_lineChart.innerGridColor = [UIColor whiteColor];
        //end
        
        //范围选择按钮
        if (self.dayDetailModel == NO) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"过去一周" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button addTarget:self action:@selector(scopeButtonTaped) forControlEvents:UIControlEventTouchUpInside];
            [_co_tableHeaderView addSubview:button];
            scopeButton = button;
            [button autoSetDimensionsToSize:CGSizeMake(ScreenWidth - 140, 30)];
            [button autoAlignAxisToSuperviewAxis:ALAxisVertical];
            [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
            UIImageView *buttonIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_arrow_up"]];
            [button addSubview:buttonIcon];
            scopeButtonIcon = buttonIcon;
            [buttonIcon autoSetDimensionsToSize:CGSizeMake(17, 17)];
            [buttonIcon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            scopeButtonIconTrailingConstraint = [buttonIcon autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];
        }
        //end
        
        //左右按钮
        if (self.dayDetailModel == NO) {
            UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonLeft setBackgroundImage:[UIImage imageNamed:@"home_zuo"] forState:UIControlStateNormal];
            [buttonLeft addTarget:self action:@selector(leftScopeButtonTaped) forControlEvents:UIControlEventTouchUpInside];
            [_co_tableHeaderView addSubview:buttonLeft];
            frontDateButton = buttonLeft;
            [buttonLeft autoSetDimensionsToSize:CGSizeMake(30, 30)];
            [buttonLeft autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:100];
            [buttonLeft autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:7];
            
            UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
            [buttonRight setBackgroundImage:[UIImage imageNamed:@"home_you"] forState:UIControlStateNormal];
            [buttonRight setBackgroundImage:[UIImage imageNamed:@"home_you_disable"] forState:UIControlStateDisabled];
            [buttonRight addTarget:self action:@selector(rightScopeButtonTaped) forControlEvents:UIControlEventTouchUpInside];
            buttonRight.enabled = NO;
            [_co_tableHeaderView addSubview:buttonRight];
            nextDateButton = buttonRight;
            [buttonRight autoSetDimensionsToSize:CGSizeMake(30, 30)];
            [buttonRight autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:100];
            [buttonRight autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:7];
        }
        //self.co_nextDayButton = buttonRight;
        //end
    }
    return _co_tableHeaderView;
}

- (UITableView *)co_tableView
{
    if (_co_tableView == nil) {
        _co_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _co_tableView.delegate = self;
        _co_tableView.dataSource = self;
        _co_tableView.backgroundColor = [UIColor clearColor];
        _co_tableView.sectionFooterHeight = 0.0f;
        _co_tableView.estimatedSectionFooterHeight = 0.0f;
        _co_tableView.tableHeaderView = nil;
        _co_tableView.tableFooterView = nil;
        
        [_co_tableView registerClass:[DKDataDetailTableViewCell class] forCellReuseIdentifier:@"DKDataDetailTableViewCell"];
        [_co_tableView registerClass:[DKDataDetailTableSectionView class] forHeaderFooterViewReuseIdentifier:@"DKDataDetailTableSectionView"];
    }
    return _co_tableView;
}

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [DKClientRequest new];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

- (DKDataDetailScopeView *)co_scopeView
{
    if (_co_scopeView == nil) {
        _co_scopeView = [DKDataDetailScopeView new];
    }
    return _co_scopeView;
}

- (NSDate *)startDate
{
    if (self.lookType == DKDataDetailLookTypeWeek) {
        _startDate = [NSString getWeekFirstDateWithWeekEndDate:self.endDate];
    }
    else {
        _startDate = [NSString getMonthFirstDateWithMonthEndDate:self.endDate];
    }
    return _startDate;
}

- (NSMutableArray *)dayDatas
{
    if (_dayDatas == nil) {
        _dayDatas = [NSMutableArray array];
    }
    return _dayDatas;
}

@end
