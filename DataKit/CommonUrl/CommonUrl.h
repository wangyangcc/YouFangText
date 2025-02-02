//
//  CommonUrl.h
//  XinHuaPublish
//
//  Created by Tiank on 14-05-02.
//
//

//接口相关
#define HTTPURL         	@"120.24.0.75"
#define HTTPURLPort	        8080
#define HTTPURLPhotoPort	8090 //头像上传端口

#define APPClientVersion 1 //客户端版本

//请求超时时间
#define RequestTimeoutInterval 30

#define App_Store_ID @"725195192"

//状态信息
#define STATUS @"error_code"
#define SUCCESS @"0"
#define DATA @"data"
#define DATAMORESIGN @"hasmore"
#define REQUEST_SUCCESS @"Success"
//end

//请求接口
//备注：REQ结尾表示请求，RESP结尾表示服务器端响应
#define SERVICE_REQ 0 //交互
#define LOGIN_REQ 3  //登录
#define HEARTBEAT_REQ 5 //心跳
#define REGIST_REQ 7  //注册
#define VALIDATE_REQ 9 //验证码
#define TERMINAL_ADD_REQ 11 //终端添加
#define TERMINAL_MOD_REQ 13 //终端修改
#define TERMINAL_DEL_REQ 15 //终端删除
#define INDEX_DAY_REQ 17 //指标天数
#define INDEX_SUM_REQ 19 //指标汇总
#define INDEX_EVA_REQ 21 //综合指数
#define VERSION_REQ 23 //版本信息
#define REMINDIMAGE_REQ 25 //提醒图片
#define CARINGNUMBER_REQ 27 //微关怀次数
#define CHECK_BINDED_REQ 29 //判断手表是否被绑定

/* 服务端定义的所有失败的原因
 FAILURE(-1, "服务器内部错误"),
 SUCCESS(0, ""),
 USER_EXIST(1, "用户已存在"),
 USER_NOTEXIST(2, "用户不存在"),
 PASSWORD_ERROR(3, "密码不正确"),
 SESSION_TIMEOUT(4, "会话已失效"),
 NOT_WEIXIN(5, "未绑定微信账号"),
 NOT_WEIBO(6, "未绑定微博账号"),
 NOT_PHONE(7,"手机号码不规范"),
 NULL_PHONE(8,"没有手机号码"),
 PHONE_NOTMATCH(9,"手机号码不正确"), //修改密码不能匹配原账户
 VERIFY_FAILURE(10,"验证码错误"),
 SCHEDULE_ERROR(11,"请传整形参数，表示秒"),
 SIGN_ERROR(12,"签到失败"),
 COMMENTPERMISSION_ERROR(13,"设置评论权限错误"),
 NOT_AUTHOR(14,"你不是该问题的作者"),
 NO_ANSWER(15,"请指定一个回答"),
 NO_QUESTION(16,"没有对应的问题"), //采纳回答的时候
 COMMENT_NOTPERMITTED(17,"不允许评论"),
 PARAM_FORMATERROR(18,"参数格式错误"),
 NO_USER(19,"请指定用户"),
 FIELD_TOLONG(20,"领域名称太长"),
 FIELD_TYPEERROR(21,"领域类型错误"),
 FORCED_EXPIRED(22,"账户在其他地方登陆，已被强制下线"),
 GETUI_NULL(23,"个推的client_id不能为空")
*/
