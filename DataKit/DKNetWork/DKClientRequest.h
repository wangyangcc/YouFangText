//
//  DKClientRequest.h
//  DataKit
//
//  Created by wangyangyang on 15/12/6.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKDeviceInfo.h"

@protocol DKClientRequestCallBackDelegate;
@interface DKClientRequest : NSObject

@property (nonatomic, weak) id<DKClientRequestCallBackDelegate> delegate;

/**
 *  请求方法tag
 */
@property (nonatomic, readonly, assign) NSInteger requestMethodTag;

/**
 *  请求得到的结果，默认空，接口请求正常时，不为空
 */
@property (nonatomic, readonly, strong) id responseObject;

/**
 *  错误结果对象，默认空，接口返回错误时，不为空
 */
@property (nonatomic, readonly, strong) NSError *error;

//获得验证码
- (void)getVerificationCodeWithAccount:(NSString *)account;

//注册
- (void)registerWithAccount:(NSString *)account
           verificationCode:(NSString *)verificationCode
                   password:(NSString *)password;

//登录
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password;

//添加新手表
- (void)addNewDeviceWithInfo:(DKDeviceInfo *)deviceInfo;

//编辑手表
- (void)editDeviceWithInfo:(DKDeviceInfo *)deviceInfo;

//删除手表
- (void)removeDeviceWithInfo:(DKDeviceInfo *)deviceInfo;

/**
 *  检查更新
 */
- (void)checkAppUpdate;

/**
 *  综合指数，根据手表id
 */
- (void)indexEvaWithSerialNumber:(NSString *)serialNumber;

/**
 *  得到手表一段时间的数据
 *
 *  @param serialNumber 手表id
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 */
- (void)serialDataWithSerialNumber:(NSString *)serialNumber
                         startDate:(NSString *)startDate
                           endDate:(NSString *)endDate;

/**
 *  上传图片
 *
 *  @param imageUrlPath 图片本地地址
 */
- (void)imageUpavatarWithImageUrlPath:(NSString *)imageUrlPath;

/**
 *  得到提醒图片地址 和 关怀的提醒次数
 */
- (void)getRemindImagePathWithAccount:(NSString *)account
                         serverNumber:(NSString *)serverNumber;

//关怀
- (void)caringWithAccount:(NSString *)account
             serverNumber:(NSString *)serverNumber
                messageId:(NSString *)messageId
               notifyTime:(NSString *)notifyTime;

//判断手表是否绑定
- (void)checkBindedWithSerialno:(NSString *)serialno;

/**
 *  错误编码
 */
+ (NSDictionary *)errorCodeDic;

@end

@protocol DKClientRequestCallBackDelegate <NSObject>

@optional

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest;

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest;

/**
 *  网络请求，从缓存中读取数据
 */
- (void)requestLoadCacheCallBack:(DKClientRequest *)clientRequest;

@end
