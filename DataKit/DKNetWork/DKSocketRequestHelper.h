//
//  DKSorcketRequestHelper.h
//  DataKit
//
//  Created by wangyangyang on 15/12/6.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKURLResponseSerialization.h"

@interface DKSocketRequestHelper : NSObject

+ (instancetype)Helper;

@property (nonatomic, copy) NSString *secssionId; /**< 手机号 */

@property (nonatomic, strong) DKSocketResponseSerialization *responseSerializer; /**< 对返回的字符串解析 */

- (void)socketRequestWithParameters:(id)parameters
                         requestTag:(long)requestTag
                             result:(void (^)(id responseObject, NSError *error))result;

//清空请求，根据tag
- (void)clearRequestWithRequestTag:(long)requestTag;

/**
 *  保存到本地
 */
- (void) saveResponseDataWithSaveId:(NSString *)saveId responseString:(NSString *)responseString;

/**
 *  读取本地缓存数据
 */
- (NSString *) readSavedResponseDataWithSaveId:(NSString *)saveId;

@end
