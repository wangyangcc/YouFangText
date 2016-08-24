//
//  DKRegisterViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/12/20.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKRegisterViewController.h"
#import "UIViewController+tapCanceGesture.h"
#import "Validate.h"
#import "NSTimer+BlockSupport.h"
#import "DKUser.h"
#import "MMAppDelegateHelper.h"
#import "DKLoginViewController.h"

@interface DKRegisterViewController () <UITextFieldDelegate>
{
    NSTimer *sendVerifyTimer;
    
    //NSString *verificationCode;
    
    NSInteger sendVerifyCountdown;//倒计时
}

/**
 *  内容试图
 */
@property (weak, nonatomic) IBOutlet UIView *ui_contentView;

/**
 *  内容试图顶部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_contentViewTopConstraint;

/**
 *  用户名
 */
@property (nonatomic, weak) IBOutlet UITextField *ui_nameField;

/**
 *  验证码
 */
@property (nonatomic, weak) IBOutlet UITextField *ui_verifyField;

/**
 *  密码
 */
@property (nonatomic, weak) IBOutlet UITextField *ui_psField;

/**
 *  密码确认
 */
@property (nonatomic, weak) IBOutlet UITextField *ui_psTwoField;


/**
 *  邀请码
 */
@property (weak, nonatomic) IBOutlet UIButton *ui_verifySendButton;

/**
 *  注册按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *ui_registerButton;

/**
 *  注册按钮顶部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_registerButtonTopConstraint;

/**
 *  标签底部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_titleBottomConstraint;


@property (strong, nonatomic) DKClientRequest *clientRequest;

@end

@implementation DKRegisterViewController

- (void)dealloc
{
    if (sendVerifyTimer) {
        [sendVerifyTimer invalidate];
        sendVerifyTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateViewStyle];
    
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        [weakSelf textFieldFrameChange:weakSelf.ui_psField isUp:NO];
        [weakSelf.view endEditing:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isLookForPassword) {
        [self.ui_registerButton setTitle:@"重置密码" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom method

- (void)updateViewStyle
{
    self.customeNavBarView.hidden = YES;
    self.ui_contentView.backgroundColor = [UIColor whiteColor];
    
    //输入框坐标的icon
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-phone"]];
    [self.ui_nameField setLeftView:leftView];
    self.ui_nameField.leftViewMode = UITextFieldViewModeAlways;
    leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify"]];
    [self.ui_verifyField setLeftView:leftView];
    self.ui_verifyField.leftViewMode = UITextFieldViewModeAlways;
    leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-password"]];
    [self.ui_psField setLeftView:leftView];
    self.ui_psField.leftViewMode = UITextFieldViewModeAlways;
    leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-password"]];
    [self.ui_psTwoField setLeftView:leftView];
    self.ui_psTwoField.leftViewMode = UITextFieldViewModeAlways;
    //end
    
    //分割线
    UIView *lineView = [UIView new];
    lineView.backgroundColor = MMRGBColor(237, 238, 239);
    [self.ui_contentView addSubview:lineView];
    [lineView autoSetDimension:ALDimensionHeight toSize:1];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.ui_nameField];
    [lineView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.ui_nameField withOffset:5];
    //end
    
    //第二条分割线
    lineView = [UIView new];
    lineView.backgroundColor = MMRGBColor(237, 238, 239);
    [self.ui_contentView addSubview:lineView];
    [lineView autoSetDimension:ALDimensionHeight toSize:1];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.ui_verifyField];
    [lineView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.ui_verifyField withOffset:5];
    //end
    
    //第三条分割线
    lineView = [UIView new];
    lineView.backgroundColor = MMRGBColor(237, 238, 239);
    [self.ui_contentView addSubview:lineView];
    [lineView autoSetDimension:ALDimensionHeight toSize:1];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.ui_psField];
    [lineView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.ui_psField withOffset:5];
    //end
    
    //第四条分割线
    lineView = [UIView new];
    lineView.backgroundColor = MMRGBColor(237, 238, 239);
    [self.ui_contentView addSubview:lineView];
    [lineView autoSetDimension:ALDimensionHeight toSize:1];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.ui_psTwoField];
    //end
    
    if ([MetaData isIphone4_4s]) {
        self.ui_registerButtonTopConstraint.constant = 13;
    }
}

- (void)getCodeRegSuccessCallBack
{
    if (sendVerifyTimer) {
        [sendVerifyTimer invalidate];
        sendVerifyTimer = nil;
    }
    
    sendVerifyCountdown = 60;
    __weak typeof(self) weakSelf = self;
    sendVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
        sendVerifyCountdown --;
        if (sendVerifyCountdown < 1) {
            [weakSelf.ui_verifySendButton setTitle:@"重新发送" forState:UIControlStateNormal];
            [weakSelf.ui_verifySendButton setEnabled:YES];
            
            [weakSelf.ui_verifySendButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
            [weakSelf.ui_verifySendButton setTitle:@"重新发送" forState:UIControlStateDisabled];
            if (sendVerifyTimer) {
                [sendVerifyTimer invalidate];
                sendVerifyTimer = nil;
            }
        }
        else {
            [weakSelf.ui_verifySendButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
            [weakSelf.ui_verifySendButton setTitle:[NSString stringWithFormat:@"重发(%d)",(int)sendVerifyCountdown] forState:UIControlStateDisabled];
        }
        
    } repeats:YES];
}

- (void)textFieldFrameChange:(UITextField *)textField
                        isUp:(BOOL)isUp
{
    CGFloat upNumber = 0;
    if (isUp) {
        upNumber = [MetaData valueForDeviceCun3_5:-145 cun4:-145 cun4_7:-40 cun5_5:-40];
    }
    
    if ((NSInteger)self.ui_contentViewTopConstraint.constant == (NSInteger)upNumber) {
        return;
    }
    self.ui_contentViewTopConstraint.constant = upNumber;
    [self.view setNeedsUpdateConstraints];
    //增加动画效果
    [UIView animateWithDuration:0.35f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - event

- (IBAction)verifySendButtonTaped:(id)sender
{
    if ([Validate isMobileNumber:self.ui_nameField.text] == NO) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确的号码"];
        [self.ui_nameField becomeFirstResponder];
        return;
    }
    [sender setEnabled:NO];
    [self.clientRequest getVerificationCodeWithAccount:self.ui_nameField.text];
}

- (IBAction)registerTaped:(id)sender
{
    if ([Validate isMobileNumber:self.ui_nameField.text] == NO) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确的号码"];
        [self.ui_nameField becomeFirstResponder];
        return;
    }
    if ([self.ui_verifyField.text length] <= 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入验证码"];
        [self.ui_verifyField becomeFirstResponder];
        return;
    }
    //判断是否输入密码
    if ([self.ui_psField.text length] <= 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        [self.ui_psField becomeFirstResponder];
        return;
    }
    //end
    //判断密码是否一致
    if ([self.ui_psField.text isEqualToString:self.ui_psTwoField.text] == NO) {
        [SVProgressHUD showInfoWithStatus:@"两次输入密码不一致"];
        [self.ui_psField becomeFirstResponder];
        return;
    }
    //end
    //界面复位
    [self textFieldFrameChange:self.ui_psField isUp:NO];
    [self.view endEditing:YES];
    [self setUserInteractionEnabled:NO];
    //end
    [SVProgressHUD show];
    [self.clientRequest registerWithAccount:self.ui_nameField.text verificationCode:self.ui_verifyField.text password:self.ui_psField.text];
}

- (IBAction)toLogin:(id)sender
{
    [self navLeftBtnTapped];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self textFieldFrameChange:textField isUp:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self textFieldFrameChange:textField isUp:NO];
    return YES;
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    //验证码
    if (clientRequest.requestMethodTag == VALIDATE_REQ) {
        NSDictionary *resultDic = clientRequest.responseObject;
        //判断是否成功
        if (resultDic[@"isSuccess"] == NO) {
            [SVProgressHUD showInfoWithStatus:[DKClientRequest errorCodeDic][resultDic[@"errorCode"]]];
            return;
        }
        //verificationCode = resultDic[@"verificationCode"];
        [self getCodeRegSuccessCallBack];
    }
    //注册接口
    else if (clientRequest.requestMethodTag == REGIST_REQ) {
        [self setUserInteractionEnabled:YES];
        //判断是否成功
        DKUser *user = [clientRequest.responseObject firstObject];
        if (user == nil) {
            [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
            return;
        }
        if (user.isSuccess == NO) {
            [SVProgressHUD showInfoWithStatus:[DKClientRequest errorCodeDic][user.errorCode]];
            return;
        }
        [[MMAppDelegateHelper shareHelper] updateWithUser:user];
        //end
        [SVProgressHUD showSuccessWithStatus:@"注册成功"];
        [MMAppDelegate loginSuccessWithUserModel:user];
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    //验证码
    if (clientRequest.requestMethodTag == VALIDATE_REQ) {
        [self.ui_verifySendButton setEnabled:YES];
        [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
    }
    //注册接口
    else if (clientRequest.requestMethodTag == REGIST_REQ) {
        [self setUserInteractionEnabled:YES];
        [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
    }
}

#pragma mark - getters and setters

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [[DKClientRequest alloc] init];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

@end
