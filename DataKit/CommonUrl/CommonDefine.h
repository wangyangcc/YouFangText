//
//  CommonDefine.h
//  TWindowPhoneStyle
//
//  Created by Tiank on 13-5-3.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#ifndef TWindowPhoneStyle_CommonDefine_h
#define TWindowPhoneStyle_CommonDefine_h


//------------------------- 系统公共 ---------------------------------------------

#import "AppDelegate.h"
#import "StatusBarObject.h"
#import "CommonUrl.h"
#import "PureLayout.h"
#import "NSObject+LogDealloc.h"
#import "UIImageView+MMSDWebImageView.h"
#import "UIButton+MMSDButtom.h"
#import "MMAlertManage.h"
#import "UIColor+HEXColor.h"
#import "UIView+LayoutMethods.h"
#import "MetaData.h"
#import "SVProgressHUD.h"
#import "CommonConst.h"
#import "UALogger.h"
#import "NSDate+dk_date.h"

#define MMAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])
#define IOS7AFTER  ([[UIDevice currentDevice] systemVersion].floatValue >= 7.0)
#define IOS8AFTER  ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0)
#define CollectionCachePath [NSString stringWithFormat:@"%@/Documents/CollectionFile",NSHomeDirectory()]
#define PicPath [NSString stringWithFormat:@"%@/Documents/Paike/",NSHomeDirectory()]
#define ScreenHeight  (IOS7AFTER ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.height - 20)
#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenWidthAdd  ([[UIScreen mainScreen] bounds].size.width - 320)
#define MMStatusBarHeight (IOS7AFTER ? CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) : CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) - 20)
#define MMNavigationBarHeight (44 + 20)
#define MMTabBarHeight 49

//----------------------------end-------------------------------------------------

#define AppName @"有方"

#define WeiChatKey @"wx6219c8343f102020"
#define WeiChatSecretKey @"71d708dd6a64829ba80f5fdd15b87e08"

#define Tencent_AppId @"1105029276"
#define Tencent_AppKey @"07ecEK2mUihzl5Hb"

//end

//分享平台渠道号  暂时未用到
#define SHARE_CHANNEL              @"channel"
#define CHANNEL_QQFRIEND           @"qq"
#define CHANNEL_QQZONE             @"Qzone"
#define CHANNEL_TENQ               @"tenq"
#define CHANNEL_SMS                @"sms"
#define CHANNEL_EMAIL              @"email"
//分享平台渠道号  用到的
#define CHANNEL_SINA               @"weibo"
#define CHANNEL_WEIXIN_FRIEND      @"weixin.hy"
#define CHANNEL_WEIXIN_TIMELINE    @"weixin.pyq"


//------------------------------- 提示语 ----------------------------------

//图文详情页面
#define SucessCollection @"收藏成功"
#define CancelCollection @"取消收藏成功"
#define SuccessSaveImg @"已保存至相册"
#define FailSaveImg @"保存失败"

#define SucessComment  @"评论成功"
#define DoneLoading @"加载完成"
#define Committing @"提交中..."

#define FailTip @"失败 再试一次"
#define Loading @"加载中..."
#define Loginning @"登录中..."
#define TappedAgain @"点击屏幕 , 重新加载"
#define NetFailTip @"请稍后重试"

#define SendingCode @"验证已经发出"
#define ErrorNo @"您输入的手机号有误"
#define RegistAlready @"您的号码已经被注册了"
#define NoPhoneNo @"请输入注册时用的手机号"
#define Erroring @"异常信息"
#define FindPasswordNull @"未发现该邮箱注册数据"

#define SuccessLogin @"登录成功"
#define NicknameNil @"您用户名是空哦"
#define PswNil @"您忘了输入密码哦"
#define NoInfo @"用户名或密码错误"
#define PswCantChange @"密码修改失败"

#define SuccessPassCode @"校验成功"
#define CodeFailCompare @"验证码错误"
#define CodeNil @"请输入验证码"
#define ErrorCode @"验证码输入有误"
#define SuccessRegist @"注册成功"
#define Registing @"注册中..."
#define PswLength @"密码位数要达到6位以上哦"
#define EmailFormat @"邮箱格式不符合哦"
#define EmailNill @"邮箱不能为空哦"
#define RepeatNickname @"这个昵称很热，很多人都在用哦"
#define RepeatEmail @"此邮箱已经被注册了，亲"
#define SuccessPsw @"修改成功"
#define SuccessAdvice @"反馈成功"
#define SuccessUpload @"上传成功,待审核"
#define TitleNil @"标题不能为空"
#define ImageNil @"请选择图片"
#define AlreadySent @"验证码已发"
#define ChineseTip @"密码需要至少6个字符（字母、数字或下划线）"

#define UploadingData @"上传中..."
#define NNameChanging @"修改中..."
#define ClearDone @"清理完成"
#define CacheClearing @"缓存清理中..."

#define Searching @"搜索中..."

//--------------------------------end---------------------------------

#define DKNavbackcolor MMRGBColor(33, 174, 229)
#define DKTabbarColor MMRGBColor(33, 174, 229)

#define MMRGBColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define MMGrayBackground [[UIImage imageNamed:@"img_greyBl"] stretchableImageWithLeftCapWidth:2 topCapHeight:2]

#endif