//
//  DKCompositeIndexViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCompositeIndexViewController.h"
#import "DKUserImageView.h"
#import "iCarousel.h"
#import "DKCompositeIndexView.h"
#import "DKCompositeIndexBottomView.h"
#import "UIImage+screenshot.h"
#import "JSONKit.h"
#import "MMSocialIconActionSheet.h"
#import "DKCompositeIndexBottomData.h"
#import "MMAppDelegateHelper.h"

#define kiCarouselHeight 345

@interface DKCompositeIndexViewController () <iCarouselDataSource, iCarouselDelegate>
{
    BOOL needUpdateWhenAppear;
    
    __weak id<NSObject> notificationOne;
    __weak id<NSObject> notificationtwo;
}

@property (nonatomic, strong) iCarousel *co_carousel;
@property (nonatomic, strong) DKCompositeIndexBottomView *co_bottomView;
@property (nonatomic, strong) DKClientRequest *clientRequest;
@property (nonatomic, strong) NSDictionary *resultDic; /**< 结果 */
@property (nonatomic, strong) DKCompositeIndexBottomData *bottomData;

@end

@implementation DKCompositeIndexViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationOne];
    [[NSNotificationCenter defaultCenter] removeObserver:notificationtwo];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __weak typeof(self) weakSelf = self;
            
            //用户选择设备改变通知
            notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
                __strong DKCompositeIndexViewController *strongWeak = weakSelf;
                strongWeak->needUpdateWhenAppear = YES;
                strongWeak.bottomData = [DKCompositeIndexBottomData new];
                strongWeak = nil;
            }];
            
            //综合指数底部数据刷新
            notificationtwo = [[NSNotificationCenter defaultCenter] addObserverForName:kCompositeIndexBottomDataChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
                __strong DKCompositeIndexViewController *strongWeak = weakSelf;
                if (note.object) {
                    strongWeak.bottomData = note.object;
                    strongWeak->needUpdateWhenAppear = YES;
                }
                strongWeak = nil;
            }];
        });    }
    return self;
}

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
    [super viewWillAppear:animated];
    
    if ([self.resultDic count] == 0 || needUpdateWhenAppear) {
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

            self.resultDic = [NSDictionary dictionary];
            [self.co_carousel scrollToItemAtIndex:0 animated:NO];
            self.co_carousel.scrollEnabled = NO;
            [self.co_carousel reloadData];
            [self.clientRequest indexEvaWithSerialNumber:[[MMAppDelegateHelper shareHelper] currentSerialNumber]];
        });
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
    if (MMAppDelegate.isShowShare) {
        self.customeNavBarView.m_navRightBtnImage = [UIImage imageNamed:@"nav_share"];
    }
    //end
    
    //底部的数值view
    self.co_bottomView = [[DKCompositeIndexBottomView alloc] initWithWidth:ScreenWidth - 20];
    [self.view addSubview:self.co_bottomView];
    [self.co_bottomView autoSetDimension:ALDimensionHeight toSize:85*ScreenWidth/375];
    [self.co_bottomView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
    [self.co_bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [self.co_bottomView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[MetaData valueForDeviceCun3_5:65 cun4:80 cun4_7:110 cun5_5:110]];
    //end
    
    //滑动部分
    [self.view addSubview:self.co_carousel];
    [self.co_carousel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.co_carousel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.co_carousel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MMNavigationBarHeight];
    [self.co_carousel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.co_bottomView withOffset:0];
    //end
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

/**
 *  更新试图
 */
- (void)updateView
{
    self.co_carousel.scrollEnabled = YES;
    [self.co_carousel reloadData];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[DKCompositeIndexView alloc] initWithFrame:CGRectMake(0, MMNavigationBarHeight, ScreenWidth, kiCarouselHeight) isLeft:index == 0];
    }
    else {
    
    }
    view.backgroundColor = [UIColor clearColor];
    
    //刷新第一页圈圈
    if (index == 0) {
        //刷新圈圈数据
        if (self.resultDic && [self.resultDic count] > 0) {
            NSString *oneDataString = self.resultDic[index == 0 ? @"lifeIndex" : @"careIndex"];
            if (oneDataString) {
                NSArray *dataArray = [oneDataString componentsSeparatedByString:@"_"];
                
                [(DKCompositeIndexView *)view updateViewWithBigNumber:[dataArray firstObject] smallNumber:[dataArray lastObject] signString:index == 0 ? @"健康指数" : @"关怀指数" isLeft:YES];
            }
        }
        else {
            [(DKCompositeIndexView *)view updateViewWithBigNumber:[@(0) stringValue] smallNumber:[@(0) stringValue] signString:index == 0 ? @"健康指数" : @"关怀指数" isLeft:YES];
        }
        //end
    }
    
    //刷新圈圈下面的数据
    if (self.bottomData) {
        [self.co_bottomView updateWithData:self.bottomData isLeft:YES];
    }
    //end
    
    //end
    return view;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 1;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(nullable UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kiCarouselHeight)];
    }
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.co_carousel.itemWidth);
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    //刷新第二页圈圈
    if (carousel.currentItemIndex == 1) {
        UIView *view = [carousel itemViewAtIndex:1];
        
        if ([self.resultDic count] > 0) {
            NSString *oneDataString = self.resultDic[@"careIndex"];
            if (oneDataString) {
                NSArray *dataArray = [oneDataString componentsSeparatedByString:@"_"];
                [(DKCompositeIndexView *)view updateViewWithBigNumber:[dataArray firstObject] smallNumber:[dataArray lastObject] signString: @"关怀指数" isLeft:NO];
            }
        }
        else {
            [(DKCompositeIndexView *)view updateViewWithBigNumber:[@(0) stringValue] smallNumber:[@(0) stringValue] signString:@"关怀指数" isLeft:NO];
        }
        
    }
    //end
    
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.5f;
        }
        case iCarouselOptionFadeMax:
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
            return value;
    }
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    self.resultDic = [clientRequest.responseObject copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateView];
    });
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    self.clientRequest = nil;
    [SVProgressHUD showInfoWithStatus:@"网络连接失败"];
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

- (iCarousel *)co_carousel
{
    if (_co_carousel == nil) {
        _co_carousel = [[iCarousel alloc] init];
        _co_carousel.delegate = self;
        _co_carousel.dataSource = self;
        _co_carousel.type = iCarouselTypeRotary;
        _co_carousel.bounces = NO;
    }
    return _co_carousel;
}

- (NSDictionary *)resultDic
{
    if (_resultDic == nil) {
        _resultDic = [NSDictionary dictionary];
    }
    return _resultDic;
}

- (DKCompositeIndexBottomView *)co_bottomView
{
    if (_co_bottomView == nil) {
        _co_bottomView = [DKCompositeIndexBottomView new];
    }
    return _co_bottomView;
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
