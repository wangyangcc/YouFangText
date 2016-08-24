//
//  DKSettingDeviceViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKSettingDeviceViewController.h"
#import "UIViewController+tapCanceGesture.h"
#import "DKSettingRelationViewController.h"
#import "MMAppDelegateHelper.h"
#import "DKClientRequest.h"

@interface DKSettingDeviceViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_contentViewTopConstraint;

@property (nonatomic, weak) IBOutlet UITextField *ui_textField;

/**
 *  用于iphone 4 下调整位置
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_titleLabelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_signLabelTopConstraint;

@property (nonatomic, strong) DKClientRequest *clientRequest;

@end

@implementation DKSettingDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateViewStyle];
    
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        [weakSelf textFieldFrameChange:weakSelf.ui_textField isUp:NO];
        [weakSelf.view endEditing:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MMAppDelegate.nav.isSlider = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MMAppDelegate.nav.isSlider = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navLeftBtnTapped
{
    //判断是否绑定过设备，如果没有，则不能退出
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    if (user.terminals == nil || [user.terminals count] == 0) {
        [SVProgressHUD showInfoWithStatus:@"请绑定一个手表"];
        return;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - custom method

- (void)updateViewStyle
{
    self.customeNavBarView.m_navTitleLabel.text = @"设置";
    
    self.ui_textField.backgroundColor = MMRGBColor(240, 241, 242);
    self.ui_textField.layer.masksToBounds = YES;
    self.ui_textField.layer.cornerRadius = 7; //圆角
    
    if ([MetaData isIphone4_4s]) {
        self.ui_titleLabelTopConstraint.constant = 15;
        self.ui_signLabelTopConstraint.constant = 220;
    }
}

- (void)textFieldFrameChange:(UITextField *)textField
                        isUp:(BOOL)isUp
{
    self.ui_contentViewTopConstraint.constant = isUp?[MetaData valueForDeviceCun3_5:-180 cun4:-150 cun4_7:-100 cun5_5:-100]: 64;
    [self.view setNeedsUpdateConstraints];
    //增加动画效果
    [UIView animateWithDuration:0.35f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - event

- (IBAction)loginTaped:(id)sender
{
    if ([self.ui_textField.text length] != 15) {
        [SVProgressHUD showInfoWithStatus:@"请输入15位的手表序列号"];
        [self.ui_textField becomeFirstResponder];
        return;
    }
    //界面复位
    [self textFieldFrameChange:self.ui_textField isUp:NO];
    [self.view endEditing:YES];
    //end
    
    [self.clientRequest checkBindedWithSerialno:self.ui_textField.text];
    [SVProgressHUD show];

}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD dismiss];
    
    DKDeviceInfo *deviceInfo = [DKDeviceInfo new];
    DKSettingRelationViewController *viewController = [[DKSettingRelationViewController alloc] init];
    
    //判断是否绑定过
    NSDictionary *result = clientRequest.responseObject;
    
    //说明绑定过
    if (result && [[result objectForKey:@"isExisted"] boolValue] == YES) {
        viewController.isBinded = YES;
        viewController.isEditModel = YES;
        deviceInfo = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKDeviceInfo") fromJSONDictionary:result[@"info"] error:nil];
    }
    else {
        viewController.isBinded = NO;
    }
    
    deviceInfo.serialNumber = self.ui_textField.text;
    viewController.deviceInfo = deviceInfo;
    [MMAppDelegate.nav pushViewController:viewController];
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self textFieldFrameChange:textField isUp:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self textFieldFrameChange:textField isUp:NO];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - getters and setters

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [DKClientRequest new];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

@end

@implementation DKSettingDeviceTextField

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 15;
    bounds.size.width = CGRectGetWidth(bounds) - 30;
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 15;
    bounds.size.width = CGRectGetWidth(bounds) - 30;
    return bounds;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 15;
    bounds.size.width = CGRectGetWidth(bounds) - 30;
    return bounds;
}


@end