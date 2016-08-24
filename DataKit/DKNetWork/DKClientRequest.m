//
//  DKClientRequest.m
//  DataKit
//
//  Created by wangyangyang on 15/12/6.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKClientRequest.h"
#import "DKSocketRequestHelper.h"
#import "MMAppDelegateHelper.h"
#import "NSString+URLEncoding.h"
#import "AFNetworking.h"

@interface DKClientRequest ()

/**
 *  请求方法tag
 */
@property (nonatomic, assign) NSInteger requestMethodTag;

/**
 *  请求得到的结果，默认空，接口请求正常时，不为空
 */
@property (nonatomic, strong) id responseObject;

/**
 *  错误结果对象，默认空，接口返回错误时，不为空
 */
@property (nonatomic, strong) NSError *error;

@end

@implementation DKClientRequest

- (void)dealloc
{
    _delegate = nil;
    
}

- (void)getVerificationCodeWithAccount:(NSString *)account
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:account?:@"0" forKey:@"phoneNum"];
    [dic setObject:[self getCurrentTimeMilliscond] forKey:@"postDate"];
    
    [self starRequestWithDic:dic requestMethodTag:VALIDATE_REQ];
}

//注册
- (void)registerWithAccount:(NSString *)account
           verificationCode:(NSString *)verificationCode
                   password:(NSString *)password
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:account?:@"0" forKey:@"account"];
    [dic setObject:verificationCode?:@"0" forKey:@"verificationCode"];
    [dic setObject:password?:@"0" forKey:@"passwd"];
    [dic setObject:[self getCurrentTimeMilliscond] forKey:@"regdate"];
   
    [self starRequestWithDic:dic requestMethodTag:REGIST_REQ];
}

//登录
- (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:account?:@"0" forKey:@"account"];
    [dic setObject:password?:@"0" forKey:@"passwd"];
    
    [self starRequestWithDic:dic requestMethodTag:LOGIN_REQ];
}

//添加新手表
- (void)addNewDeviceWithInfo:(DKDeviceInfo *)deviceInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userId = [[MMAppDelegateHelper shareHelper] currentUserId];
    [dic setObject:userId?:@"0" forKey:@"accountId"];
    [dic setObject:deviceInfo.serialNumber?:@"0" forKey:@"serialno"];
    [dic setObject:@(deviceInfo.sex) forKey:@"sex"];
    [dic setObject:deviceInfo.height?:@"0" forKey:@"height"];
    [dic setObject:deviceInfo.weight?:@"0" forKey:@"weight"];
    [dic setObject:deviceInfo.birthday?:@"0" forKey:@"birthday"];
    [dic setObject:deviceInfo.relation?:@"0" forKey:@"relation"];
    [dic setObject:deviceInfo.bloodPressure?:@"0" forKey:@"bloodp"];
    [dic setObject:deviceInfo.bloodSugar?:@"0" forKey:@"bloodg"];
    [dic setObject:deviceInfo.photoPath?:@"" forKey:@"photoUrl"];
    
    [self starRequestWithDic:dic requestMethodTag:TERMINAL_ADD_REQ];
}

//编辑手表
- (void)editDeviceWithInfo:(DKDeviceInfo *)deviceInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userId = [[MMAppDelegateHelper shareHelper] currentUserId];
    [dic setObject:userId?:@"0" forKey:@"accountId"];
    [dic setObject:deviceInfo.serialNumber?:@"0" forKey:@"serialno"];
    [dic setObject:@(deviceInfo.sex) forKey:@"sex"];
    [dic setObject:deviceInfo.height?:@"0" forKey:@"height"];
    [dic setObject:deviceInfo.weight?:@"0" forKey:@"weight"];
    [dic setObject:deviceInfo.birthday?:@"0" forKey:@"birthday"];
    [dic setObject:deviceInfo.relation?:@"0" forKey:@"relation"];
    [dic setObject:deviceInfo.bloodPressure?:@"0" forKey:@"bloodp"];
    [dic setObject:deviceInfo.bloodSugar?:@"0" forKey:@"bloodg"];
    [dic setObject:deviceInfo.photoPath?:@"" forKey:@"photoUrl"];
    [dic setObject:deviceInfo.target?:@"" forKey:@"target"];
    
    [self starRequestWithDic:dic requestMethodTag:TERMINAL_MOD_REQ];
}

//删除手表
- (void)removeDeviceWithInfo:(DKDeviceInfo *)deviceInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userId = [[MMAppDelegateHelper shareHelper] currentUserId];
    [dic setObject:userId?:@"0" forKey:@"accountId"];
    [dic setObject:@[deviceInfo.serialNumber?:@"0"] forKey:@"deleteTerminals"];

    [self starRequestWithDic:dic requestMethodTag:TERMINAL_DEL_REQ];
}

/**
 *  检查更新
 */
- (void)checkAppUpdate
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [self starRequestWithDic:dic requestMethodTag:VERSION_REQ];
}

/**
 *  综合指数，根据手表id
 */
- (void)indexEvaWithSerialNumber:(NSString *)serialNumber
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:serialNumber?:@"0" forKey:@"serialno"];
    //缓存设置
    [dic setValue:[NSString stringWithFormat:@"%@|INDEXEVA", serialNumber] forKey:kResponseModel_LocalSaveId_Sign];
    
    [self starRequestWithDic:dic requestMethodTag:INDEX_EVA_REQ];
}

/**
 *  得到手表一段时间的数据
 *
 *  @param serialNumber 手表id
 *  @param startDate    开始时间
 *  @param endDate      结束时间
 */
- (void)serialDataWithSerialNumber:(NSString *)serialNumber
                         startDate:(NSString *)startDate
                           endDate:(NSString *)endDate
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:serialNumber?:@"0" forKey:@"serialno"];
    [dic setValue:startDate?:@"0" forKey:@"startDate"];
    [dic setValue:endDate?:@"0" forKey:@"endDate"];
    if (serialNumber && [endDate isEqualToString:startDate]) {
        //缓存设置
        [dic setValue:[NSString stringWithFormat:@"%@|%@|SERIALDATA", serialNumber,startDate] forKey:kResponseModel_LocalSaveId_Sign];
    }

    [self starRequestWithDic:dic requestMethodTag:INDEX_DAY_REQ];
}

/**
 *  上传图片
 *
 *  @param imageUrlPath 图片本地地址
 */
- (void) imageUpavatarWithImageUrlPath:(NSString *)imageUrlPath
{
    NSMutableDictionary *sysParams = [[NSMutableDictionary alloc] init];
    [sysParams setObject:imageUrlPath forKey:@"file"];
    [sysParams setObject:@"image" forKey:@"file_type"];
    
    NSString *urlPath = [NSString stringWithFormat:@"http://%@:%d/datakit-file-server/servlet/UploadHandleServlet",HTTPURL, HTTPURLPhotoPort];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperation *operation = [manager POST:urlPath parameters:sysParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        __weak id<AFMultipartFormData> weakFormData = formData;
        //添加要上传到http body 字段的值
        [sysParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSData *dataUpload = [NSData dataWithContentsOfFile:obj];
            if (dataUpload) {
                [weakFormData appendPartWithFileData:dataUpload name:key fileName:@"userText.png" mimeType:@"image/png"];
            }
        }];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UALogger log:@"头像上传接口--成功--返回值----%@",responseObject];
        weakSelf.responseObject = responseObject;
        weakSelf.error = nil;
        [weakSelf.delegate requestDidSuccessCallBack:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.responseObject = nil;
        weakSelf.error = error;
        [weakSelf.delegate requestDidFailCallBack:self];
        [UALogger log:@"头像上传接口--失败--返回值----%@",error];
    }];
    [manager.operationQueue addOperation:operation];
}

/**
 *  得到提醒图片地址 和 关怀的提醒次数
 */
- (void)getRemindImagePathWithAccount:(NSString *)account
                         serverNumber:(NSString *)serverNumber
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:serverNumber?:@"" forKey:@"serialno"];
    [dic setValue:account?:@"" forKey:@"accountId"];
    //缓存设置
    [dic setValue:[NSString stringWithFormat:@"%@|%@|CARING",account, serverNumber] forKey:kResponseModel_LocalSaveId_Sign];
    
    [self starRequestWithDic:dic requestMethodTag:REMINDIMAGE_REQ];
}

//关怀
- (void)caringWithAccount:(NSString *)account
             serverNumber:(NSString *)serverNumber
                messageId:(NSString *)messageId
               notifyTime:(NSString *)notifyTime
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:serverNumber?:@"" forKey:@"serialno"];
    [dic setValue:account?:@"" forKey:@"accountId"];
    [dic setValue:messageId?:@"" forKey:@"msgid"];
    [dic setValue:notifyTime?:@"" forKey:@"notifyTime"];

    [self starRequestWithDic:dic requestMethodTag:SERVICE_REQ];
}

//判断手表是否绑定
- (void)checkBindedWithSerialno:(NSString *)serialno;
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:serialno?:@"" forKey:@"serialno"];
    
    [self starRequestWithDic:dic requestMethodTag:CHECK_BINDED_REQ];
}

/**
 *  错误编码
 */
+ (NSDictionary *)errorCodeDic
{
    return @{
             @(1001) : @"账号已经存在",
             @(1002) : @"验证码错误",
             @(1003) : @"密码长度必须大于6字符",
             @(1004) : @"密码长度不得大于16字符",
             @(1005) : @"账号长度不得大于16字符",
             @(1006) : @"账号不能为空",
             @(1007) : @"密码不能为空",
             @(1008) : @"验证码不能为空",
             @(1009) : @"昵称不能超过32个字符",
             @(1010) : @"昵称被占用",
             @(1011) : @"登录失败，用户名或密码错误!",
             @(1012) : @"验证码已经失效",
             @(1013) : @"绑定失败，手表号已经被绑定",
             };
}

#pragma mark - custom method

- (void)starRequestWithDic:(NSMutableDictionary *)dic
          requestMethodTag:(NSInteger)requestMethodTag
{
    if (dic) {
        [dic setObject:[@(requestMethodTag) stringValue] forKey:kSocketRequestMethodPort];
    }
    //long 在32位机器上 最大值 2147483647
    //long 在64位机器上 最大值和 long long 相同 9223372036854775807
    __weak typeof(self) weakSelf = self;
    [[DKSocketRequestHelper Helper] socketRequestWithParameters:dic requestTag:[self getNewRequestTag] result:^(id responseObject, NSError *error) {
        [UALogger log:@" resultBlock socket 开始调用"];
        __strong DKClientRequest *strongSelf = weakSelf;
        strongSelf.requestMethodTag = requestMethodTag;
        strongSelf.responseObject = responseObject;
        strongSelf.error = error;
        if (error) {
            //判断是否有本地保存的数据
            if ([[dic allKeys] containsObject:kResponseModel_LocalSaveId_Sign]) {
                NSString *saveString = [[DKSocketRequestHelper Helper] readSavedResponseDataWithSaveId:dic[kResponseModel_LocalSaveId_Sign]];
                if (saveString) {
                    NSError *errorTmp = nil;
                    id responseObjectTmp = nil;
                    @try {
                        responseObjectTmp = [[DKSocketRequestHelper Helper].responseSerializer responseObjectForRequestParams:dic dataString:saveString error:&errorTmp];
                    }
                    @catch (NSException *exception) {
                        [strongSelf.delegate requestDidFailCallBack:weakSelf];
                    }
                    //从缓存中读取
                    strongSelf.responseObject = responseObjectTmp;
                    strongSelf.error = error;
                    [strongSelf.delegate requestLoadCacheCallBack:weakSelf];
                }
                else {
                    [strongSelf.delegate requestDidFailCallBack:weakSelf];
                }
            }
            //end
            else {
                [strongSelf.delegate requestDidFailCallBack:weakSelf];
            }
        }
        else {
            [strongSelf.delegate requestDidSuccessCallBack:weakSelf];
        }
        [UALogger log:@" resultBlock socket 调用结束"];
    }];
    //end
}

- (NSString *)getCurrentTimeMilliscond
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970]*1000;
    return [@(time) stringValue];
}

- (long)getNewRequestTag
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HHmmssSSS"];
    return (long)[[dateFormatter stringFromDate:[NSDate dk_date]] longLongValue];
}

@end
