//
//  MMAppDelegateHelper.h
//  Datakit
//
//  Created by wangyangyang on 15/6/23.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKUser.h"
#import "DKUserCaringObject.h"

/**
 *  全局的，负责需要序列化的对象的序列化
 */
@interface MMAppDelegateHelper : NSObject

+ (MMAppDelegateHelper *)shareHelper;

#pragma mark - 用户登录相关

//用户登录相关
- (DKUser *)currentUser;
- (NSString *)currentUserId;
- (NSString *)currentAccountNumber;
- (NSString *)currentSerialNumber;
- (void)updateWithUser:(DKUser *)user;
- (void)userLoginOut:(BOOL)clearViewControllers;

/**
 *  清楚试图控制器堆栈，并返回到首页
 */
- (void)clearViewControllersToHomeAnimated:(BOOL)animated;

#pragma mark - 微关怀保存

//添加新的用户关怀数据
- (void)addNewUserCaringWithObject:(DKUserCaringObject *)newObject;

//得到对于的用户关怀数据，为空，说明没关怀过
- (DKUserCaringObject *)getUserCaringWithCaringId:(NSString *)caringId;

//保存用户关怀数据
- (void)saveUserCaringData;


@end
