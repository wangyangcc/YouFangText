//
//  CustomeSuperViewController.m
//  QiongHai
//
//  Created by Tiank on 14-2-23.
//  Copyright (c) 2014年 xhmm. All rights reserved.
//

#import "GeneralSuperViewController.h"
#import "UIButton+Block.h"

@interface GeneralSuperViewController ()
{
    UIButton *interactionEnabledButton;
    
    UIView *requestFailFreshView; /**< 重新加载的界面 */
    UIView *promptTextView; /**< 默认问题提示界面 */
}

@end

@implementation GeneralSuperViewController

- (void)dealloc
{
    _customeNavBarView = nil;
    if (self.dismmProgressHUDWhenDealloc) {
        [SVProgressHUD dismiss];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //自定义导航栏背景View
    self.customeNavBarView = [[MmNavBarView alloc] initWithFrame:CGRectMake(0, (MMStatusBarHeight > 20 ? 20 : 0), ScreenWidth, MMNavigationBarHeight - (MMStatusBarHeight > 20 ? 20 : 0))];
    self.customeNavBarView.backgroundColor = [UIColor blackColor];
    self.customeNavBarView.m_navBarDelegate = self;
    self.customeNavBarView.m_navLeftBtnImage = [UIImage imageNamed:@"nav_return_normal"];
    //        self.customeNavBarView.m_navRightBtnImage = [UIImage imageNamed:@"home_right"];
    //end
    
    [self.view addSubview:self.customeNavBarView];
    
    self.dismmProgressHUDWhenDealloc = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dismmProgressHUDWhenDealloc = YES;
    //设置滑动条的起始位置，从0开始
    self.automaticallyAdjustsScrollViewInsets = NO;
}

// 设置状态栏类型，默认为白色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark-
#pragma mark 控件事件处理

- (void)navLeftBtnTapped
{
    //返回上一页
    [MMAppDelegate.nav popViewController];
}

-(void)navRightBtnTapped
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 网络失败提示试图

- (void)showNetworkErrorWithCallBack:(SEL)callBack
{
    [self hideDefaultText];
    
    //请求失败无数据的提示图片
    UIView *requestFailFreshBtnBl = [[UIView alloc] initWithFrame:self.view.bounds];
    requestFailFreshBtnBl.backgroundColor = [UIColor whiteColor];
    
    UIButton *requestFailFreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    requestFailFreshBtn.frame = requestFailFreshBtnBl.bounds;
    requestFailFreshBtn.backgroundColor = [UIColor clearColor];
    [requestFailFreshBtn setImage:[UIImage imageNamed:@"img_placeHolder_errorNetwork_nor"] forState:UIControlStateNormal];
    [requestFailFreshBtn setImage:[UIImage imageNamed:@"img_placeHolder_errorNetwork_pre"] forState:UIControlStateHighlighted];
//    [requestFailFreshBtn setTitle:TextDefaultErrorNetwork forState:UIControlStateNormal];
//    requestFailFreshBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [requestFailFreshBtn setTitleColor:[UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1] forState:UIControlStateNormal];
    __weak GeneralSuperViewController *superVC = self;
    __weak UIView *freshBtmBl = requestFailFreshBtnBl;
    [requestFailFreshBtn setAction:kUIButtonBlockTouchUpInside withBlock:^{
        [freshBtmBl removeFromSuperview];
        [superVC performSelectorOnMainThread:callBack withObject:nil waitUntilDone:NO];
    }];
    [requestFailFreshBtnBl addSubview:requestFailFreshBtn];
    
    if (requestFailFreshView) {
        [requestFailFreshView removeFromSuperview];
        requestFailFreshView = nil;
    }
    requestFailFreshView = requestFailFreshBtnBl;
    
    [self.view insertSubview:requestFailFreshBtnBl belowSubview:self.customeNavBarView];
}

/**
 *   @brief 根据文字显示默认的提示界面
 **/
- (void)showDefaultPromptWithText:(NSString *)defaultText
{
    [self showPromptTextWithText:defaultText iconImage:@"img_placeHolder_noData"];
}

/**
 *  显示提示界面
 *
 *  @param defaultText 内容
 *  @param iconImage   icon
 */
- (UIView *)showPromptTextWithText:(NSString *)defaultText
                         iconImage:(NSString *)iconImage
{
    if (requestFailFreshView) {
        [requestFailFreshView removeFromSuperview];
        requestFailFreshView = nil;
    }
    
    if (promptTextView) {
        return promptTextView;
    }
    UIView *defaultView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:iconImage];
    imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    imageView.center = CGPointMake(CGRectGetWidth(defaultView.frame)/2, CGRectGetHeight(defaultView.frame)/2 - 50);
    [defaultView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, CGRectGetWidth(defaultView.frame), 46)];
    titleLabel.text = defaultText;
    titleLabel.textColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:19];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [defaultView addSubview:titleLabel];
    
    promptTextView = defaultView;
    
    [self.view insertSubview:defaultView belowSubview:self.customeNavBarView];
    
    return defaultView;
}

- (void)hideDefaultText
{
    if (promptTextView) {
        [promptTextView removeFromSuperview];
        promptTextView = nil;
    }
}

/**
 *  设置是否接受响应，除了导航条
 *
 *  @param enabled bool值
 */
- (void)setUserInteractionEnabled:(BOOL)enabled
{
    if (enabled && interactionEnabledButton) {
        [interactionEnabledButton removeFromSuperview];
        interactionEnabledButton = nil;
    }
    else if (enabled == NO && interactionEnabledButton == nil){
        interactionEnabledButton = [UIButton buttonWithType:UIButtonTypeCustom];
        interactionEnabledButton.frame = CGRectMake(0, MMNavigationBarHeight, ScreenWidth, ScreenHeight - MMNavigationBarHeight);
        [self.view insertSubview:interactionEnabledButton belowSubview:self.customeNavBarView];
    }
}

@end

@implementation YANetworkErrorButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, CGRectGetHeight(self.frame)/2, CGRectGetWidth(contentRect), 21);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    UIImage *image = [self imageForState:UIControlStateNormal];
    return CGRectMake((CGRectGetWidth(self.frame) - image.size.width)/2, CGRectGetHeight(self.frame)/2 - image.size.height - 20, image.size.width, image.size.height);
}

@end