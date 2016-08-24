//
//  DKUser.h
//  DataKit
//
//  Created by wangyangyang on 15/12/10.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"
#import "DKDeviceInfo.h"

@interface DKUser : MTLModel <MTLJSONSerializing>

/**
 *  用户id，一般是手机号码
 */
@property (nonatomic, copy) NSString *userId;

/**
 *  终端数组
 */
@property (nonatomic, copy) NSArray *terminals;

/**
 *  当前选择的手表序列化，可能为空
 */
@property (nonatomic, copy) NSString *selectedSerialNumber;

/**
 *  错误编码，详见 [DKClientRequest errorCodeDic]
 */
@property (nonatomic, copy) NSNumber *errorCode;

/**
 *  是否成功
 */
@property (nonatomic, assign) BOOL isSuccess;

/**
 *  得到当前选择的手表设备信息
 */
- (DKDeviceInfo *)getSelectedDeviceInfo;

@end
