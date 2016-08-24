//
//  DKCaringViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCaringViewController.h"
#import "DKUserImageView.h"
#import "DKCaringCollectionViewCell.h"
#import "DKCaringObject.h"
#import "MMAppDelegateHelper.h"

@interface DKCaringViewController () <UICollectionViewDataSource, UICollectionViewDelegate, DKCaringCollectionViewCellProtocol>
{
    __weak id<NSObject> notificationOne;
    __weak id<NSObject> notificationTwo;
    BOOL needUpdateWhenAppear;
}

@property (nonatomic, strong) NSMutableArray *markArrays; /**< 标记列表 */

@property (nonatomic, strong) UICollectionView *co_collectionView;

@property (nonatomic, strong) DKClientRequest *clientRequest;

@end

@implementation DKCaringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateViewStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.co_collectionView reloadData];
    if ([self.markArrays count] == 0 || needUpdateWhenAppear) {
        needUpdateWhenAppear = NO;
        
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
        });
        
        [SVProgressHUD show];
        if ([self.markArrays count] > 0) {
            self.markArrays = [NSMutableArray array];
            [self.co_collectionView reloadData];
        }
        [self.clientRequest getRemindImagePathWithAccount:[[MMAppDelegateHelper shareHelper] currentAccountNumber] serverNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber]];
    }
}

#pragma mark - custom method

- (void)updateViewStyle
{
    //设置导航条
    self.customeNavBarView.m_navTitleLabel.text = AppName;
    self.customeNavBarView.m_navLeftBtn.hidden = YES;
    DKUserImageView *userImage = [[DKUserImageView alloc] init];
    [self.customeNavBarView addSubview:userImage];
    [userImage autoSetDimensionsToSize:CGSizeMake(50, 44)];
    [userImage autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [userImage autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    //end
    
    //标记列表
    [self.view addSubview:self.co_collectionView];
    [self.co_collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(MMNavigationBarHeight, 0, 49, 0)];
    //end
    
    __weak typeof(self) weakSelf = self;
    
    //用户选择设备改变通知
    notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __strong DKCaringViewController *strongWeak = weakSelf;
        strongWeak->needUpdateWhenAppear = YES;
        strongWeak = nil;
    }];
    //首页点击 血压 关怀
    notificationTwo = [[NSNotificationCenter defaultCenter] addObserverForName:kHomeBloodUpdateCaringVC_Sign object:nil queue:nil usingBlock:^(NSNotification *note) {
        __strong DKCaringViewController *strongWeak = weakSelf;
        [strongWeak.co_collectionView reloadData];
        strongWeak = nil;
    }];
    
}

#pragma mark - DKCaringCollectionViewCellProtocol

- (void)remindButtonTaped:(NSIndexPath *)indexPath
{
    [SVProgressHUD show];
    DKCaringObject *caringObject = [self.markArrays objectAtIndex:indexPath.row];
    long long time = (long long)[[NSDate date] timeIntervalSince1970]*1000;
    
    [self.clientRequest caringWithAccount:[[MMAppDelegateHelper shareHelper] currentAccountNumber] serverNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber] messageId:caringObject.caringId notifyTime:[@(time) stringValue]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.markArrays count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DKCaringCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DKCaringCollectionViewCell" forIndexPath:indexPath];
    cell.c_delegate = self;
    [cell setContentWithObject:self.markArrays AtIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ((int)ScreenWidth <= 320) {
        return CGSizeMake(160, 230);
    }
    return CGSizeMake((int)180*ScreenWidth/375, 259*ScreenWidth/375);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ((int)ScreenWidth <= 320) {
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    if (clientRequest.requestMethodTag == REMINDIMAGE_REQ) {
        self.markArrays = clientRequest.responseObject;
        [self.co_collectionView reloadData];
        [SVProgressHUD dismiss];
    }
    else if (clientRequest.requestMethodTag == SERVICE_REQ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"提醒了"];
        });
        //刷新列表
        [self.co_collectionView reloadData];
    }
}

/**
 *  网络请求，从缓存中读取数据
 */
- (void)requestLoadCacheCallBack:(DKClientRequest *)clientRequest
{
    if (clientRequest.requestMethodTag == REMINDIMAGE_REQ) {
        self.markArrays = clientRequest.responseObject;
        [self.co_collectionView reloadData];
        [SVProgressHUD showInfoWithStatus:@"网络连接失败"];
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    self.clientRequest = nil;
    [SVProgressHUD showInfoWithStatus:@"网络连接失败"];
}


#pragma mark - getters and setters

- (NSMutableArray *)markArrays
{
    if (_markArrays == nil) {
        _markArrays = [NSMutableArray array];
    }
    return _markArrays;
}

- (UICollectionView *)co_collectionView
{
    if (_co_collectionView == nil) {
        _co_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
        _co_collectionView.backgroundColor = [UIColor clearColor];
        _co_collectionView.delegate = self;
        _co_collectionView.dataSource = self;
        _co_collectionView.alwaysBounceVertical = YES;
        [_co_collectionView registerNib:[UINib nibWithNibName:@"DKCaringCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"DKCaringCollectionViewCell"];
    }
    return _co_collectionView;
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
