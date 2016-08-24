//
//  DKHomeViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKHomeViewController.h"
#import "CustomIOSAlertView.h"
#import "DKAlertSexEditView.h"
#import "DKUserImageView.h"
#import "MyTableView.h"
#import "DKDateCalendarView.h"
#import "DKSerialDayData.h"
#import "DKUserSportIndex.h"
#import "DKUserRecordViewController.h"
#import "DKUserRecordData.h"
#import "NSObject+dateFormat.h"
#import "DKHomeIndexData.h"
#import "MMAppDelegateHelper.h"
#import "DKDataDetailViewController.h"
#import "DKHomeTableViewCell.h"
#import "UIImage+screenshot.h"
#import "MMSocialIconActionSheet.h"

#define kListNumber 7

@interface DKHomeViewController () <MyTableViewDelegate, MyTableViewExpandDelegate>
{
    BOOL needUpdateWhenAppear;
    
    NSDate *todayDate;
    
    __weak id<NSObject> notificationOne;
    __weak id<NSObject> notificationTwo;
    __weak id<NSObject> notificationThree;
    __weak id<NSObject> notificationFour;
}

/**
 *  顶部功能栏的东西
 */
@property (nonatomic, strong) UIView *co_dateSelectionView;
@property (nonatomic, strong) UILabel *co_dateLabel;
@property (nonatomic, strong) UIButton *co_nextDayButton;

@property (nonatomic, strong) DKDateCalendarView *co_dateCalendarView;

@property (nonatomic, strong) MyTableView *co_tableView;
@property (nonatomic, strong) DKClientRequest *clientRequest;
@property (nonatomic, strong) NSDate *currentLookDate; /** 当前查看的日期 */
@property (nonatomic, strong) DKUserRecordData *userMaxData; /** 用户历史最大数据 */

@end

@implementation DKHomeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationThree];
    [[NSNotificationCenter defaultCenter] removeObserver:notificationTwo];
    [[NSNotificationCenter defaultCenter] removeObserver:notificationOne];
    [[NSNotificationCenter defaultCenter] removeObserver:notificationFour];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateViewStyle];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak typeof(self) weakSelf = self;
        
        //用户登录状态改变 通知
        notificationTwo = [[NSNotificationCenter defaultCenter] addObserverForName:kUserLoginStateChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//            __strong YAHomeViewController *strongWeak = weakSelf;
//            strongWeak->needUpdateWhenAppear = YES;
//            strongWeak = nil;
        }];
    
        //用户选择设备改变通知
        notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            __strong DKHomeViewController *strongWeak = weakSelf;
            strongWeak->needUpdateWhenAppear = YES;
            //重置到今天的时间
            strongWeak.currentLookDate = strongWeak->todayDate;
            [strongWeak dateSelectedChange];
            strongWeak = nil;
        }];
        
        //用户点击血压
        notificationThree = [[NSNotificationCenter defaultCenter] addObserverForName:kHomeBloodTaped_Sign object:nil queue:nil usingBlock:^(NSNotification *note) {
            __strong DKHomeViewController *strongWeak = weakSelf;
            [SVProgressHUD show];
            long long time = (long long)[[NSDate dk_date] timeIntervalSince1970]*1000;
            
            [strongWeak.clientRequest caringWithAccount:[[MMAppDelegateHelper shareHelper] currentAccountNumber] serverNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber] messageId:@"msg_blood" notifyTime:[@(time) stringValue]];
            
            strongWeak = nil;
        }];
        
        //首页数据更新
        notificationFour = [[NSNotificationCenter defaultCenter] addObserverForName:kHomeVCUpdateDataNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            __strong DKHomeViewController *strongWeak = weakSelf;
            strongWeak->needUpdateWhenAppear = YES;
            strongWeak = nil;
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self.co_tableView tableData] count] == 0 || needUpdateWhenAppear) {
        needUpdateWhenAppear = NO;
        if ([self.co_tableView.tableData count] > 0) {
            self.co_tableView.tableData = [NSMutableArray array];
            [self.co_tableView reloadData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //更新手表名
            DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
            if (user) {
                DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
                self.customeNavBarView.m_navTitleLabel.text = [NSString stringWithFormat:@"%@的手表",deviceInfo.relation];
            }
            else {
                self.customeNavBarView.m_navTitleLabel.text = AppName;
            }
            //end
            
            //移动到顶部
            if ([self.co_tableView.tableData count] > 0) {
                [self.co_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            [self.co_tableView dragAnimation];
            [self myTableViewLoadDataAgain];
            
            
        });
    }
}

#pragma mark - custom method

- (void)updateViewStyle
{
    //设置导航条
    if (MMAppDelegate.isShowShare) {
        self.customeNavBarView.m_navRightBtnImage = [UIImage imageNamed:@"nav_share"];
    }
    self.customeNavBarView.m_navLeftBtn.hidden = YES;
    DKUserImageView *userImage = [[DKUserImageView alloc] init];
    [self.customeNavBarView addSubview:userImage];
    [userImage autoSetDimensionsToSize:CGSizeMake(50, 44)];
    [userImage autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [userImage autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    //end
    
    //添加时间选择栏
    [self.view addSubview:self.co_dateSelectionView];
    [self.co_dateSelectionView autoSetDimension:ALDimensionHeight toSize:56];
    [self.co_dateSelectionView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_dateSelectionView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_dateSelectionView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MMNavigationBarHeight - (MMStatusBarHeight > 20 ? 20 : 0)];
    //end
    
    //添加表格
    [self.view addSubview:self.co_tableView];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:49];
    [self.co_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.co_dateSelectionView];
    //end
    
}

- (void)addTestData
{
    NSArray *data = @[
                      @{@"title":@"走了1000步", @"icon": @"运动首页_14-26"},
                      @{@"title":@"行走10.6公里", @"icon": @"运动首页_39"},
                      @{@"title":@"睡了9小时", @"icon": @"运动首页_39-54"},
                      @{@"title":@"心率BMP70", @"icon": @"运动首页_56"},
                      @{@"title":@"共消耗900大卡", @"icon": @"运动首页_58"},
                      @{@"title":@"个人记录", @"icon": @"运动首页_60"},
                      ];
    self.co_tableView.tableData = [NSMutableArray arrayWithArray:data];
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

- (void)navTitleLabelTapped
{
    if ([self.co_dateCalendarView isShowed] == NO) {
        __weak typeof(self) weakSelf = self;
        [self.co_dateCalendarView setLookDate:^(NSDate *date) {
            weakSelf.currentLookDate = [NSObject formatDateWithDate:date];
            [weakSelf dateSelectedChange];
        }];
        [self.co_dateCalendarView showWithSelectedDate:self.currentLookDate];
    }
}

/**
 *  选择的时间改变
 */
- (void)dateSelectedChange
{
    if (self.currentLookDate == todayDate) {
        self.co_nextDayButton.enabled = NO;
        self.co_dateLabel.text = @"今天";
    }
    else {
        self.co_nextDayButton.enabled = YES;
        self.co_dateLabel.text = [NSObject homeTitleFormatStringWithDate:self.currentLookDate];
    }
    self.co_tableView.tableData = [NSMutableArray array];
    [self.co_tableView reloadData];
    [self.co_tableView dragAnimation];
    [self myTableViewLoadDataAgain];
}

#pragma mark - event

- (void)lastDayTaped
{
    self.currentLookDate = [NSObject yesterdayFormatDateWithDate:self.currentLookDate];
    [self dateSelectedChange];
}

- (void)nextDayTaped
{
    self.currentLookDate = [NSObject tomorrowFormatDateWithDate:self.currentLookDate];
    [self dateSelectedChange];
}

#pragma mark - MyTableViewDelegate

- (void)myTableViewLoadDataAgain
{
    [self.clientRequest serialDataWithSerialNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber] startDate:[NSObject requestParameterFormatDateWithDate:self.currentLookDate] endDate:[NSObject requestParameterFormatDateWithDate:self.currentLookDate]];
}

- (CGFloat)myTableRowHeightAtIndex:(NSIndexPath *)indexPath
{
    return 68;
}

- (void)myTabledidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < kListNumber - 1) {
        DKHomeTableViewCell *cell = [self.co_tableView cellForRowAtIndexPath:indexPath];
        
        DKDataDetailViewController *detailVC = [DKDataDetailViewController new];
        detailVC.detailTypeParameter = cell.dataIndex[indexPath.row];
        detailVC.detailTypeName = cell.dataIndexName[indexPath.row];
        detailVC.detailUnitName = cell.dataUnitName[indexPath.row];
        detailVC.isDoubleChart = [cell isDoubleChart];
        [MMAppDelegate.nav pushViewController:detailVC];
    }
    else {
        DKUserRecordViewController *vc = [DKUserRecordViewController new];
        vc.recordData = self.userMaxData;
        [MMAppDelegate.nav pushViewController:vc];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.co_tableView.tableData count] == 0) {
        return 0;
    }
    return kListNumber;
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    //关怀
    if (clientRequest.requestMethodTag == SERVICE_REQ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"提醒了"];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeBloodUpdateCaringVC_Sign object:nil];
        return;
    }
    //格式化数据
    NSDictionary *resultDic = clientRequest.responseObject;
    if ([resultDic[@"isSuccess"] boolValue] == NO) {
        [SVProgressHUD showErrorWithStatus:[DKClientRequest errorCodeDic][resultDic[@"errorCode"]]];
        [self.co_tableView doneLoadingTableViewData];
        return;
    }
    NSError *error = nil;
    //获取历史最大数据
    NSDictionary *userMaxDataDic = resultDic[@"maxData"];
    self.userMaxData = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKUserRecordData") fromJSONDictionary:userMaxDataDic error:&error];
    if (self.userMaxData == nil) {
        self.userMaxData = [DKUserRecordData new];
    }
    //end
    
    //获取天数据
    NSDictionary *dayDatas = resultDic[@"dayDatas"];
    DKHomeIndexData *homeListModel = nil;
    NSDictionary *dayData = [NSDictionary dictionary];
    if (dayDatas) {
        dayData = dayDatas[[[dayDatas allKeys] firstObject]?:@""];
        homeListModel = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKHomeIndexData") fromJSONDictionary:dayData[@"dayData"] error:&error];
        
        /* 首页界面中血压跟心率取天最新上报值 按天跟小时查看时候分别取其平均值 */
        
        //心率取值
        homeListModel.heart = dayData[@"lastHeart"];
        //高压 和 低压 取值
        homeListModel.lblood = dayData[@"lastLblood"];
        homeListModel.hblood = dayData[@"lastHblood"];
    }
   
    if (homeListModel == nil) {
        homeListModel = [DKHomeIndexData new];
        homeListModel.walk = @"0";
        homeListModel.distance = @"0";
        homeListModel.heart = @"0";
        homeListModel.lowSleep = @"0";
        homeListModel.calorie = @"0";
        homeListModel.sleep = @"0";
    }
    self.co_tableView.tableData = [NSMutableArray arrayWithObject:homeListModel];
    [self.co_tableView doneLoadingTableViewData];
    
    //获取当天最大数据，显示在综合指数界面
    if ([self.currentLookDate compare:todayDate] == NSOrderedSame) {
        //综合指数底部数据刷新
        MTLModel *compositeIndexModel = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKCompositeIndexBottomData") fromJSONDictionary:dayData[@"dayData"] error:&error];
        [compositeIndexModel setValue:dayData[@"lastHeart"] forKey:@"heart"];
        if (compositeIndexModel == NO) {
            compositeIndexModel = [NSClassFromString(@"DKCompositeIndexBottomData") new];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCompositeIndexBottomDataChangeNotification object:compositeIndexModel];
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
    //关怀
    if (clientRequest.requestMethodTag != SERVICE_REQ) {
        [self.co_tableView doneLoadingTableViewData];
    }
}

/**
 *  网络请求，从缓存中读取数据
 */
- (void)requestLoadCacheCallBack:(DKClientRequest *)clientRequest
{
    [self requestDidSuccessCallBack:clientRequest];
    [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
}

#pragma mark - getters and setters

- (UIView *)co_dateSelectionView
{
    if (_co_dateSelectionView == nil) {
        _co_dateSelectionView = [[UIView alloc] init];
        _co_dateSelectionView.backgroundColor = DKNavbackcolor;
        
        UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLeft setBackgroundImage:[UIImage imageNamed:@"home_zuo"] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(lastDayTaped) forControlEvents:UIControlEventTouchUpInside];
        [_co_dateSelectionView addSubview:buttonLeft];
        [buttonLeft autoSetDimensionsToSize:CGSizeMake(30, 30)];
        [buttonLeft autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [buttonLeft autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:13];
        
        UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonRight setBackgroundImage:[UIImage imageNamed:@"home_you"] forState:UIControlStateNormal];
        [buttonRight setBackgroundImage:[UIImage imageNamed:@"home_you_disable"] forState:UIControlStateDisabled];
        [buttonRight addTarget:self action:@selector(nextDayTaped) forControlEvents:UIControlEventTouchUpInside];
        buttonRight.enabled = NO;
        [_co_dateSelectionView addSubview:buttonRight];
        [buttonRight autoSetDimensionsToSize:CGSizeMake(30, 30)];
        [buttonRight autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [buttonRight autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:13];
        self.co_nextDayButton = buttonRight;
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:20];
        label.text = @"今天";
        [_co_dateSelectionView addSubview:label];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTitleLabelTapped)];
        [label addGestureRecognizer:tap];
        self.co_dateLabel = label;
        [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:70];
        [label autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:70];
        [label autoSetDimension:ALDimensionHeight toSize:25];
        [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    }
    return _co_dateSelectionView;
}

- (MyTableView *)co_tableView
{
    if (_co_tableView == nil) {
        _co_tableView = [[MyTableView alloc] init];
        [_co_tableView setMyTable_delegate:self];
        _co_tableView.cellNameString = @"DKHomeTableViewCell";
        [_co_tableView setCellDelegateObject:self];
        [_co_tableView setTableDelegateObject:self];
        [_co_tableView setfreshHeaderView:YES];
        [_co_tableView setFooterViewHidden:YES];
        _co_tableView.backgroundColor = MMRGBColor(244, 245, 246);
        _co_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _co_tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _co_tableView;
}

- (DKDateCalendarView *)co_dateCalendarView
{
    if (_co_dateCalendarView == nil) {
        _co_dateCalendarView = [[DKDateCalendarView alloc] init];
    }
    return _co_dateCalendarView;
}

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [DKClientRequest new];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

- (NSDate *)currentLookDate
{
    if (_currentLookDate == nil) {
        todayDate = [NSObject toadyFormatDate];
        _currentLookDate = [todayDate copy];
    }
    return _currentLookDate;
}

@end
