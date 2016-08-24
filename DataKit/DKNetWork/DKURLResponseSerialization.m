//
//  DKURLResponseSerialization.m
//  DataKit
//
//  Created by wangyangyang on 15/12/10.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKURLResponseSerialization.h"
#import "JSONKit.h"

@implementation DKSocketResponseSerialization

#pragma mark - DKURLResponseSerialization

- (id)responseObjectForRequestParams:(NSDictionary *)requestParams
                          dataString:(NSString *)dataString
                               error:(NSError *__autoreleasing *)error
{
    if (dataString == nil || requestParams == nil) {
        return nil;
    }
    id responseObject = [dataString objectFromJSONString];
    NSString *responseMethod = [requestParams objectForKey:kSocketRequestMethodPort];
    
    //判断是否需要对单个接口解析
    NSMutableArray *mutableArray = [NSMutableArray array];
    //登录接口
    if ([responseMethod integerValue] == LOGIN_REQ || [responseMethod integerValue] == REGIST_REQ) {
        MTLModel *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKUser") fromJSONDictionary:responseObject error:error];
        if (model) {
            [mutableArray addObject:model];
        }
    }
    //设备添加接口 设备编辑接口
    else if ([responseMethod integerValue] == TERMINAL_ADD_REQ || [responseMethod integerValue] == TERMINAL_MOD_REQ) {
        MTLModel *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKDeviceInfo") fromJSONDictionary:responseObject error:error];
        if (model) {
            [mutableArray addObject:model];
        }
        else {

            
        }
    }
    //得到提醒次数
    else if ([responseMethod integerValue] == REMINDIMAGE_REQ) {
        responseObject = responseObject[@"data"];
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
            [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MTLModel *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKCaringObject") fromJSONDictionary:obj error:error];
                if (model) {
                    [mutableArray addObject:model];
                }
            }];
        }
    }
    //end
    
    
    //返回结果
    if ([mutableArray count] > 0) {
        return mutableArray;
    }
    return responseObject;
}

@end
