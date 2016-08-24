//
//  DKAccountSwitchViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKAccountSwitchViewController.h"
#import "MMAppDelegateHelper.h"
#import "NSString+URLEncoding.h"
#import "UIImageView+WebCache.h"
#import "MGSwipeButton.h"
#import "DKSettingRelationViewController.h"

@interface DKAccountSwitchViewController () <UITableViewDataSource, UITableViewDelegate, MMAlertManageDelegate, MGSwipeTableCellDelegate>
{
    NSInteger selectedIndex;
}

@property (nonatomic, strong) UITableView *co_tableView;

@property (nonatomic, strong) NSMutableArray *tableDataArray;

@property (nonatomic, strong) DKClientRequest *clientRequest;

@end

@implementation DKAccountSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedIndex = -1;
    [self updateViewStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MMAppDelegate.nav.isSlider = NO;
    [self performSelector:@selector(updateData) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MMAppDelegate.nav.isSlider = YES;
}

#pragma mark - custom method

- (void)navLeftBtnTapped
{
    //判断是否选择了设备，如果没有，则不能返回
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    //判断是否绑定了设备，如果没绑定，则跳转到绑定界面
    if (user.terminals == nil || [user.terminals count] == 0) {
        [SVProgressHUD showInfoWithStatus:@"请添加设备"];
    }
    //end
    //判断是否已有当前选择的设置，如果没有，则跳转到设备选择界面
    else if (user.selectedSerialNumber == nil || [user.selectedSerialNumber length] == 0)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择设备"];
    }
    else {
        //发送通知刷新用户切换的设备
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserSelectedDeviceChangeNotification object:nil];
        //end
        //nav 选择第一个
        [MMAppDelegate.tabbarVC setSelectedIndex:0];
        
        if (MMAppDelegate.nav == MMAppDelegate.rootNav) {
            [super navLeftBtnTapped];
        }
        else {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

- (void)updateViewStyle
{
    self.view.backgroundColor = MMRGBColor(244, 245, 246);
    //设置导航条
    self.customeNavBarView.m_navTitleLabel.text = @"账户";
    //end
    
    [self.view addSubview:self.co_tableView];
    [self.co_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(MMNavigationBarHeight, 0, 0, 0)];
}

//更新数据
- (void)updateData
{
    self.tableDataArray = [[[MMAppDelegateHelper shareHelper] currentUser].terminals mutableCopy];
    //判断用户选择的是那个设备
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    NSObject *selectedDevice = [user getSelectedDeviceInfo];
    if (selectedDevice == nil) {
        selectedIndex = -1;
    }
    else {
        selectedIndex = [self.tableDataArray indexOfObject:selectedDevice];
    }
    //end
    [self.co_tableView reloadData];
}

/**
 *  注销账号
 */
- (void)accountLoginOut
{
    MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
    alertManage.tag = 111;
    [alertManage showInView:[MMAppDelegate.nav view]];
}

/**
 *  切换用户设备
 */
- (void)changeUserDevice:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    [self.co_tableView reloadData];
    
    //更新用户选择的手表信息
    DKDeviceInfo *deviceInfo = self.tableDataArray[indexPath.row];
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    user.selectedSerialNumber = deviceInfo.serialNumber;
    [[MMAppDelegateHelper shareHelper] updateWithUser:user];
    //end

}

/**
 *  添加设备
 */
- (void)addUserDevice
{
    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:[NSClassFromString(@"DKSettingDeviceViewController") new]];
    [MMAppDelegate.nav presentViewController:nav animated:YES completion:NULL];
}

-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSArray * titles = @[@"删除", @"编辑"];
    NSArray * colors = @[[UIColor redColor], [UIColor lightGrayColor]];
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.tableDataArray count] + 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {
        return 55;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellWithIdentifier = indexPath.section == 0 ? (indexPath.row < [self.tableDataArray count] ? @"cellWithIdentifier1" : @"cellWithIdentifier2") : @"cellWithIdentifier3";
    DKAccountSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    if (cell == nil) {
        cell = [[DKAccountSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellWithIdentifier];
        
        //第一分区，用户数据
        if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {

            UIImageView *selectedImage = [[UIImageView alloc] init];
            selectedImage.tag = 100;
            selectedImage.image = [UIImage imageNamed:@"accout_selected"];
            selectedImage.frame = CGRectMake(ScreenWidth - 22 - 26, 15, 26, 25);
            selectedImage.hidden = YES;
            [cell.contentView addSubview:selectedImage];
        }
        //第一分区，添加按钮
        else if (indexPath.section == 0) {
            cell.textLabel.text = @"              添加设备";
            cell.textLabel.textColor = DKTabbarColor;
            cell.isSmallImage = YES;
            cell.iconImageView.image = [UIImage imageNamed:@"accout_add"];
        }
        //第二分区
        else if (indexPath.section == 1) {
            cell.textLabel.text = @"注销当前账号";
        }
        //end
    }
    
    //第一分区，用户数据
    if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {
        DKDeviceInfo *deviceInfo = self.tableDataArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"              %@的手表",deviceInfo.relation];
        
        UIImageView *selectedIcon = [cell viewWithTag:100];
        selectedIcon.hidden = (indexPath.row != selectedIndex);
        
        //设置头像
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:deviceInfo.photoPath] placeholderImage:[UIImage imageNamed:deviceInfo.sex == 1 ? @"user_default_woman" : @"user_default_man"]];
        //end
        
        cell.delegate = self;
        cell.leftSwipeSettings.transition = MGSwipeTransitionBorder;
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        cell.leftExpansion.buttonIndex = -1;
        cell.leftExpansion.fillOnTrigger = NO;
        cell.rightExpansion.buttonIndex = -2;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.leftButtons = @[];
        cell.rightButtons = [self createRightButtons:2];
    }
    return cell;
}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {
//        return YES;
//    }
//    return NO;
//}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {
//        return UITableViewCellEditingStyleDelete;
//    }
//    return UITableViewCellEditingStyleNone;
//}

//- (void)  tableView:(UITableView *)tableView
// commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//  forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete){
//        
//        
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //第一分区，用户数据
    if (indexPath.section == 0 && indexPath.row < [self.tableDataArray count]) {
        [self changeUserDevice:indexPath];
    }
    //第一分区，添加按钮
    else if (indexPath.section == 0) {
        [self addUserDevice];
    }
    //第二分区
    else if (indexPath.section == 1) {
        [self accountLoginOut];
    }
    //end
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    
    if (direction == MGSwipeDirectionRightToLeft) {
        //编辑
        if (index == 1) {
            DKSettingRelationViewController *vc = [DKSettingRelationViewController new];
            vc.deviceInfo = self.tableDataArray[[self.co_tableView indexPathForCell:cell].row];
            vc.isEditModel = YES;
            MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:vc];
            [MMAppDelegate.nav presentViewController:nav animated:YES completion:NULL];
            return YES;
        }
        //delete button
        NSIndexPath *indexPath = [self.co_tableView indexPathForCell:cell];
        
        DKDeviceInfo *delDeviceInfo = self.tableDataArray[indexPath.row];
        [self.co_tableView beginUpdates];
        [self.co_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableDataArray removeObjectAtIndex:indexPath.row];
        [self.co_tableView endUpdates];
        [self setUserInteractionEnabled:NO];
        
        //判断用户选择的是不是这一样
        if (indexPath.row == selectedIndex) {
            selectedIndex = -1;
            //更新用户选择的手表信息
            DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
            user.selectedSerialNumber = nil;
            //            user.terminals = self.tableDataArray;
            [[MMAppDelegateHelper shareHelper] updateWithUser:user];
            //end
        }
        //end
        
        [SVProgressHUD show];
        //调用接口 请求
        [self.clientRequest removeDeviceWithInfo:delDeviceInfo];
        //end
        
    }
    
    return YES;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction
{
    if (direction == MGSwipeDirectionLeftToRight) {
        return NO;
    }
    return YES;
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive
{
}

#pragma mark - MMAlertManageDelegate


- (void)actionSheet:(MMAlertManage *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [[MMAppDelegateHelper shareHelper] userLoginOut:YES];
        [MMAppDelegate presentLoginVCWithAnimated:NO];
        [MMAppDelegate.rootNav popViewController];
    }
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    [self setUserInteractionEnabled:YES];
    [SVProgressHUD dismiss];
    //删除成功后，更新本地缓存
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    user.terminals = [self.tableDataArray copy];
    [[MMAppDelegateHelper shareHelper] updateWithUser:user];
    //end
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [self setUserInteractionEnabled:YES];
    [SVProgressHUD showErrorWithStatus:@"请稍后重试"];
    [self updateData];
}

#pragma mark - getters and setters

- (UITableView *)co_tableView
{
    if (_co_tableView == nil) {
        _co_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _co_tableView.backgroundColor = [UIColor clearColor];
        _co_tableView.backgroundView = nil;
        _co_tableView.delegate = self;
        _co_tableView.dataSource = self;
    }
    return _co_tableView;
}

- (NSMutableArray *)tableDataArray
{
    if (_tableDataArray == nil) {
        _tableDataArray = [NSMutableArray array];
    }
    return _tableDataArray;
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

@implementation DKAccountSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageVIew = [UIImageView new];
        _iconImageView = imageVIew;
        [self.contentView addSubview:imageVIew];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isSmallImage) {
        _iconImageView.frame = CGRectMake(23, 5, 28, 29);
    }
    else {
        _iconImageView.frame = CGRectMake(15, 5, 44, 44);
    }
}

@end
