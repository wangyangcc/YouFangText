//
//  DKUserRecordViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUserRecordViewController.h"
#import "MMAppDelegateHelper.h"
#import "NSString+URLEncoding.h"
#import "DKUserRecordData.h"
#import "DKUserRecordTableViewCell.h"
#import "UIViewController+tapCanceGesture.h"
#import "SVProgressHUD.h"
#import "UIImage+screenshot.h"
#import "MMSocialIconActionSheet.h"

#define kTableHeaderHei 100

@interface DKUserRecordViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSString *fieldWalk;
    NSString *fieldSleep;
}

@property (nonatomic, strong) UIView *co_tableHeader;
@property (nonatomic, strong) UILabel *co_titleLabel; /** 历史最佳记录 */

@property (nonatomic, strong) UITableView *co_tableView;

@property (strong, nonatomic) NSMutableArray *tableDatas;

@property (nonatomic, strong) DKClientRequest *clientRequest;

@end

@implementation DKUserRecordViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (MMAppDelegate.isShowShare) {
        self.customeNavBarView.m_navRightBtnImage = [UIImage imageNamed:@"nav_share"];
    }
    [self.view addSubview:self.co_tableHeader];
    [self.co_tableHeader autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MMNavigationBarHeight];
    [self.co_tableHeader autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_tableHeader autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_tableHeader autoSetDimension:ALDimensionHeight toSize:kTableHeaderHei];
    
    [self.view addSubview:self.co_tableView];
    [self.co_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(MMNavigationBarHeight + kTableHeaderHei, 0, 0, 0)];
    
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        [weakSelf.view endEditing:YES];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self tableDatas] count] == 0) {
        [self updateViewStyle];
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

#pragma mark - custom method

- (void)updateViewStyle
{
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    if (user) {
        DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
        self.customeNavBarView.m_navTitleLabel.text = [NSString stringWithFormat:@"%@的手表",deviceInfo.relation];
        self.co_titleLabel.text = [NSString stringWithFormat:@"%@历史最佳成绩",deviceInfo.relation];
        
        self.tableDatas = [NSMutableArray arrayWithObject:self.recordData?:[NSNull null]];
        [self.co_tableView reloadData];
    }
}

- (void)fieldChange:(NSNotification *)noti
{
    UITextField *field = noti.object;
    if (field.tag == 111) {
        fieldWalk = field.text;
    }
    else if (field.tag == 112) {
        fieldSleep = field.text;
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 80 : 50;
}

- (void)myTabledidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.tableDatas count] == 0) {
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tableDatas count] == 0) {
        return 0;
    }
    return section == 0 ? 5 : 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = indexPath.section == 0 ? @"DKUserRecordTableViewCell" : @"DKUserRecordTextFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[DKUserRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *field = [[UITextField alloc] init];
            field.tag = 111 + indexPath.row;
            field.placeholder = indexPath.row == 0 ? @"输入步数目标(步)" : @"输入睡眠时长目标(小时)";
            field.keyboardType = UIKeyboardTypeNumberPad;
            field.textAlignment = indexPath.row == 0 ? NSTextAlignmentRight : UIKeyboardTypeNumbersAndPunctuation;
            field.delegate = self;
            field.layer.masksToBounds = YES;
            field.layer.cornerRadius = 3.0f;
            field.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
            [cell.contentView addSubview:field];
            [field autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(8, 120, 8, 15)];
        }
    }
    
    if (indexPath.section == 0) {
        [(DKUserRecordTableViewCell *)cell setContentWithObject:self.tableDatas AtIndexPath:indexPath];
    }
    else {
        cell.textLabel.text = indexPath.row == 0 ? @"步数目标" : @"睡眠目标";
        DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
        
        UITextField *field = [cell.contentView viewWithTag:111 + indexPath.row];
        DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
        NSArray *arrays = [deviceInfo.target componentsSeparatedByString:@"#"];
        if (indexPath.row == 0) {
            field.text = [arrays firstObject];
            fieldWalk = field.text;
        }
        else {
            field.text = [arrays lastObject];
            fieldSleep = field.text;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 0 : 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *footerView = [[UIView alloc] init];
    footerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 70);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = DKNavbackcolor;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0f;
    [button setTitle:@"保存运动目标" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTestButton:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    [button autoSetDimension:ALDimensionHeight toSize:40];
    [button autoSetDimension:ALDimensionWidth toSize:200];
    [button autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
    return footerView;
}

- (void)onTestButton:(UIButton*)button
{
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    if (user) {
        [self.view endEditing:YES];
        [self.co_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        //判断睡眠格式
        if (fieldSleep && [fieldSleep hasPrefix:@"."]) {
            //自动拼接0
            fieldSleep = [NSString stringWithFormat:@"0%@", fieldSleep];
        }
        //精确到小数点后两位
        if (fieldSleep) {
            fieldSleep = [NSString stringWithFormat:@"%.2f",[fieldSleep floatValue]];
        }
        
        [SVProgressHUD show];
        DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
        deviceInfo.target = [NSString stringWithFormat:@"%@#%@", fieldWalk?:@"", fieldSleep];
        [self.clientRequest editDeviceWithInfo:deviceInfo];
        [[MMAppDelegateHelper shareHelper] updateWithUser:user];
    }
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD showSuccessWithStatus:@"设置成功"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHomeVCUpdateDataNotification object:nil];
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.co_tableView setContentOffset:CGPointMake(0, CGRectGetMinY([self.co_tableView rectForSection:1]) + [MetaData valueForDeviceCun3_5:27 cun4:27 cun4_7:-30 cun5_5:-50]) animated:YES];
    return YES;
}

#pragma mark - getters and setters

- (UIView *)co_tableHeader
{
    if (_co_tableHeader == nil) {
        _co_tableHeader = [UIView new];//101 82
        
        //顶部背景
        UIView *topView = [UIView new];
        topView.backgroundColor = DKNavbackcolor;
        [_co_tableHeader addSubview:topView];
        [topView autoSetDimension:ALDimensionHeight toSize:kTableHeaderHei/2];
        [topView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [topView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [topView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        //end
        
        //icon
        UIImageView *icon = [UIImageView new];
        icon.image = [UIImage imageNamed:@"login_icon2"];
        [_co_tableHeader addSubview:icon];
        [icon autoSetDimensionsToSize:CGSizeMake(102, 82)];//205 165
        [icon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [icon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
//        [icon autoSetDimensionsToSize:CGSizeMake(82, 82)];
//        [icon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
//        [icon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:30];
        //end
        
        //文本
        UILabel *titleLabe = [UILabel new];
        titleLabe.backgroundColor = [UIColor clearColor];
        titleLabe.textColor = [UIColor whiteColor];
        titleLabe.font = [UIFont systemFontOfSize:16];
        [_co_tableHeader addSubview:titleLabe];
        self.co_titleLabel= titleLabe;
        [titleLabe autoSetDimension:ALDimensionHeight toSize:20];
        [titleLabe autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTableHeaderHei/2 - 20 - 10];
        [titleLabe autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:130];
        [titleLabe autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        //end
    }
    return _co_tableHeader;
}

- (NSMutableArray *)tableDatas
{
    if (_tableDatas == nil) {
        _tableDatas = [NSMutableArray array];
    }
    return _tableDatas;
}

- (UITableView *)co_tableView
{
    if (_co_tableView == nil) {
        _co_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _co_tableView.delegate = self;
        _co_tableView.dataSource = self;
        _co_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _co_tableView.backgroundColor = MMRGBColor(244, 245, 246);
        _co_tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
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

@end
