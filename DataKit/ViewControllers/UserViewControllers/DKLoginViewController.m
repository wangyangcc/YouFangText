//
//  DKLoginViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKLoginViewController.h"
#import "UIViewController+tapCanceGesture.h"
#import "Validate.h"
#import "WXApi.h"
#import "DKUser.h"
#import "MMAppDelegateHelper.h"
#import "DKRegisterViewController.h"

@interface DKLoginViewController () <UITextFieldDelegate> //, WXApiDelegate, TencentLoginDelegate,TencentSessionDelegate

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
 *  密码
 */
@property (nonatomic, weak) IBOutlet UITextField *ui_psField;

/**
 *  登录按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *ui_loginButton;

/**
 *  第三方登录View 底部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_otherLoginViewBottomConstraint;

/**
 *  标签底部约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_titleBottomConstraint;

//@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@property (strong, nonatomic) DKClientRequest *clientRequest;

@end

@implementation DKLoginViewController

- (void)dealloc
{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateViewStyle];
    
    self.ui_titleBottomConstraint.constant = [MetaData valueForDeviceCun3_5:-30 cun4:-30 cun4_7:-40 cun5_5:-50];
    
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        [weakSelf textFieldFrameChange:weakSelf.ui_psField isUp:NO];
        [weakSelf.view endEditing:YES];
    }];
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
    self.ui_otherLoginViewBottomConstraint.constant = [MetaData valueForDeviceCun3_5:10 cun4:46 cun4_7:86 cun5_5:86];
    
    //输入框坐标的icon
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-phone"]];
    [self.ui_nameField setLeftView:leftView];
    self.ui_nameField.leftViewMode = UITextFieldViewModeAlways;
    leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-password"]];
    [self.ui_psField setLeftView:leftView];
    self.ui_psField.leftViewMode = UITextFieldViewModeAlways;
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
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [lineView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.ui_psField];
    //end
    
}

- (void)textFieldFrameChange:(UITextField *)textField
                        isUp:(BOOL)isUp
{
    if (textField == self.ui_psField) {
        if ((NSInteger)ScreenWidth <= 320) {
            self.ui_contentViewTopConstraint.constant = isUp?([MetaData isIphone4_4s] ? -150: -60): 0;
            [self.view setNeedsUpdateConstraints];
            //增加动画效果
            [UIView animateWithDuration:0.35f animations:^{
                [self.view layoutIfNeeded];
            }];
        }
    }
    else if ((NSInteger)ScreenWidth <= 320) {
        self.ui_contentViewTopConstraint.constant = [MetaData isIphone4_4s] ? -150: -60;
        [self.view setNeedsUpdateConstraints];
        //增加动画效果
        [UIView animateWithDuration:0.35f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - event

- (IBAction)loginTaped:(id)sender
{
    if ([Validate isMobileNumber:self.ui_nameField.text] == NO) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确的号码"];
        [self.ui_nameField becomeFirstResponder];
        return;
    }
    if ([self.ui_psField.text length] <= 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        [self.ui_psField becomeFirstResponder];
        return;
    }
//    //判断验证码是否正确
//    if (verificationCode == nil || [self.ui_psField.text isEqualToString:verificationCode] == NO) {
//        [SVProgressHUD showInfoWithStatus:@"请输入正确的验证码"];
//        [self.ui_psField becomeFirstResponder];
//        return;
//    }
//    //end
//    if ([self.ui_nameField.text isEqualToString:@"15957131921"]) {
//        MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:@"小惊喜" message:@"给你准备的，天天开心哟!^_^" delegate:nil cancelButtonTitle:@"我会的" otherButtonTitles:nil, nil];
//        [alertManage show];
//    }
    //界面复位
    [self textFieldFrameChange:self.ui_psField isUp:NO];
    [self.view endEditing:YES];
    //end
    [SVProgressHUD show];
    [self.clientRequest loginWithAccount:self.ui_nameField.text password:self.ui_psField.text];
}

- (IBAction)weixinLoginTaped:(id)sender
{
    //判断用户是否安装了微信
    if ([WXApi isWXAppInstalled] == NO) {
        [SVProgressHUD showInfoWithStatus:@"您没有安装微信，请先下载安装"];
        return;
    }
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact,post_timeline,sns";
    req.state = [MetaData getBundleId];
    req.openID = @"0c806938e2413ce73eef92cc3";
    
//    [WXApi sendAuthReq:req viewController:self delegate:self];
}

- (IBAction)qqLoginTaped:(id)sender
{
//    //判断用户是否安装了qq
//    if ([QQApiInterface isQQInstalled] == NO) {
//        [SVProgressHUD showInfoWithStatus:@"您没有安装QQ，请先下载安装"];
//        return;
//    }
//    NSArray *_permissions = [NSArray arrayWithObjects:
//                             kOPEN_PERMISSION_GET_USER_INFO,
//                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
//                             kOPEN_PERMISSION_ADD_ALBUM,
//                             kOPEN_PERMISSION_ADD_IDOL,
//                             kOPEN_PERMISSION_ADD_ONE_BLOG,
//                             kOPEN_PERMISSION_ADD_PIC_T,
//                             kOPEN_PERMISSION_ADD_SHARE,
//                             kOPEN_PERMISSION_ADD_TOPIC,
//                             kOPEN_PERMISSION_CHECK_PAGE_FANS,
//                             kOPEN_PERMISSION_DEL_IDOL,
//                             kOPEN_PERMISSION_DEL_T,
//                             kOPEN_PERMISSION_GET_FANSLIST,
//                             kOPEN_PERMISSION_GET_IDOLLIST,
//                             kOPEN_PERMISSION_GET_INFO,
//                             kOPEN_PERMISSION_GET_OTHER_INFO,
//                             kOPEN_PERMISSION_GET_REPOST_LIST,
//                             kOPEN_PERMISSION_LIST_ALBUM,
//                             kOPEN_PERMISSION_UPLOAD_PIC,
//                             kOPEN_PERMISSION_GET_VIP_INFO,
//                             kOPEN_PERMISSION_GET_VIP_RICH_INFO,
//                             kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
//                             kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
//                             nil];
//    [self.tencentOAuth authorize:_permissions inSafari:NO];
}

- (IBAction)registerTaped:(id)sender
{
    [MMAppDelegate.nav pushViewController:[NSClassFromString(@"DKRegisterViewController") new]];
}

- (IBAction)lookForPasswordTaped:(id)sender
{
    DKRegisterViewController *vc = [DKRegisterViewController new];
    vc.isLookForPassword = YES;
    [MMAppDelegate.nav pushViewController:vc];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self textFieldFrameChange:textField isUp:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 200) {
        [textField resignFirstResponder];
        [self loginTaped:nil];
        return YES;
    }
    if (textField.tag == 100) {
        [self.ui_psField becomeFirstResponder];
    }
    return YES;
}


#pragma mark - WXApiDelegate

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    SendAuthResp *respTmp = (SendAuthResp *)resp;
    //判断是否是取消登录
    if (respTmp.code == nil) {
        return;
    }
    //end
    [self setUserInteractionEnabled:NO];
    [SVProgressHUD show];
    
//    //获取appid
//    NSString *urlPathStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&grant_type=authorization_code&code=%@",WeiChatKey,WeiChatSecretKey,[NSString stringWithFormat:@"%@",respTmp.code]];
//    
//    NSError *serializationError = nil;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSMutableURLRequest *requestOne = [manager.requestSerializer requestWithMethod:@"GET" URLString:urlPathStr parameters:nil error:&serializationError];
//    requestOne.timeoutInterval = RequestTimeoutInterval;
//    
//    __weak typeof(self) weakSelf = self;
//    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:requestOne success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *openId = [responseObject objectForKey:@"openid"];
//        NSString *accessToken = [responseObject objectForKey:@"access_token"];
//        //NSLog(@"微信登录得到的openId:%@",openId);
//        [weakSelf.clientRequest loginWithPhone:@"" password:@"" weixinId:openId weiboId:@"" accessToken:accessToken];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [weakSelf setUserInteractionEnabled:YES];
//        [SVProgressHUD showErrorWithStatus:NetFailTip];
//    }];
//    [manager.operationQueue addOperation:operation];
//    //end
}

#pragma mark - qq 登录相关

//- (void)tencentDidLogin
//{
//    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
//    {
//        // 记录登录用户的OpenID、Token以及过期时间
//        [_tencentOAuth getUserInfo];
//    }
//    else
//    {
//       [SVProgressHUD showErrorWithStatus:@"登录失败，请稍后重试"];
//    }
//}
//
//-(void)tencentDidNotLogin:(BOOL)cancelled
//{
//    if (cancelled)
//    {
//        //NSLog(@"用户取消登录");
//    }
//    else
//    {
//        [SVProgressHUD showErrorWithStatus:@"登录失败，请稍后重试"];
//    }
//}
//
//-(void)tencentDidNotNetWork
//{
//    [SVProgressHUD showErrorWithStatus:@"无网络连接，请检查网络"];
//}
//
//- (BOOL)onTencentReq:(TencentApiReq *)req
//{
//    return YES;
//}
//
//- (BOOL)onTencentResp:(TencentApiResp *)resp
//{
//    return YES;
//}
//
//- (void)getUserInfoResponse:(APIResponse*) response
//{
//    //NSDictionary *useInfo = [NSMutableDictionary dictionaryWithDictionary:response.jsonResponse];
//    //[self.myRequest userOpenregLoginWithUserType:@"3002" publicKey:_tencentOAuth.openId nickName:useInfo[@"nickname"] headImage:useInfo[@"figureurl_qq_2"]];
//}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    if (clientRequest.requestMethodTag == LOGIN_REQ) {
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
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        [MMAppDelegate loginSuccessWithUserModel:user];
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    if (clientRequest.requestMethodTag == LOGIN_REQ) {
        [SVProgressHUD showInfoWithStatus:@"请稍后重试"];
    }
}

#pragma mark - getters and setters 

//- (TencentOAuth *)tencentOAuth
//{
//    if (_tencentOAuth == nil) {
//        //_tencentOAuth = [[TencentOAuth alloc] initWithAppId:Tencent_AppId andDelegate:self];
//    }
//    return _tencentOAuth;
//}

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [[DKClientRequest alloc] init];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

@end

@implementation DKLoginTextField

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 40;
    bounds.size.width = CGRectGetWidth(bounds) - 50;
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 40;
    bounds.size.width = CGRectGetWidth(bounds) - 50;
    return bounds;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 40;
    bounds.size.width = CGRectGetWidth(bounds) - 50;
    return bounds;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect boundsNew = CGRectZero;
    boundsNew.origin.x = 0;
    boundsNew.size.width = 28;
    boundsNew.size.height = 28;
    boundsNew.origin.y = CGRectGetHeight(bounds)/2 - CGRectGetHeight(boundsNew)/2;
    return boundsNew;
}

@end