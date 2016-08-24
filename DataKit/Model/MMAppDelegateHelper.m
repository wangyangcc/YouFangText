//
//  MMAppDelegateHelper.m
//  Datakit
//
//  Created by wangyangyang on 15/6/23.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMAppDelegateHelper.h"
#import "NSString+MD5Addition.h"
#import "JSONKit.h"

@interface MMAppDelegateHelper ()
{
    __weak id<NSObject> notificationOne;
}

@property (nonatomic,strong,readwrite) DKUser *user;
@property (nonatomic, copy) NSString *userFilePath;
@property (nonatomic,strong) dispatch_queue_t ioQueue;

/**
 *  判断是不是在每次启动客户端的时候，已经显示过提示语
 */
@property (nonatomic, assign) BOOL isShowedPromteEveryRuning;

@property (nonatomic, copy) NSString *userCaringFilePath;
@property (nonatomic, strong) NSMutableArray *userCaringArrays;

@end

@implementation MMAppDelegateHelper

+ (MMAppDelegateHelper *)shareHelper
{
    static MMAppDelegateHelper *helper;
    static dispatch_once_t onece_t_p;
    dispatch_once(&onece_t_p, ^{
        helper = [[MMAppDelegateHelper alloc] init];
        helper.ioQueue = dispatch_queue_create("youwen.MMAppDelegateHelper.queue", DISPATCH_QUEUE_SERIAL);
    });
    return helper;
}

- (NSString *)userFilePath
{
    if (_userFilePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        _userFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"userFile" stringFromMD5]];
    }
    return _userFilePath;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //更新系统未读消息通知
        __weak typeof(self) weakSelf = self;
        notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            weakSelf.userCaringFilePath = nil;
            weakSelf.userCaringArrays = nil;
        }];
    }
    return self;
}

- (DKUser *)currentUser
{
    if ([MMAppDelegateHelper shareHelper].user == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.userFilePath] == NO) {
            return nil;
        }
        [MMAppDelegateHelper shareHelper].user = [NSKeyedUnarchiver unarchiveObjectWithFile:self.userFilePath];
    }
    
    return [MMAppDelegateHelper shareHelper].user;
}

- (NSString *)currentUserId
{
    if ([MMAppDelegateHelper shareHelper].user == nil) {
        return @"0";
    }
    
    return [MMAppDelegateHelper shareHelper].user.userId;
}

- (NSString *)currentAccountNumber
{
//    return @"138000000001";
    return [self currentUserId];
}

- (NSString *)currentSerialNumber
{
    if ([MMAppDelegateHelper shareHelper].user == nil) {
        return @"0";
    }
//    return @"138000000001";
    return [MMAppDelegateHelper shareHelper].user.selectedSerialNumber;
}

- (void)updateWithUser:(DKUser *)user
{
    if (user) {
        dispatch_async([MMAppDelegateHelper shareHelper].ioQueue, ^()
                       {
                           [NSKeyedArchiver archiveRootObject:user toFile:self.userFilePath];
                           [MMAppDelegateHelper shareHelper].user = user;
                       });
    }else {
        [MMAppDelegateHelper shareHelper].user = nil;
        [[NSFileManager defaultManager]removeItemAtPath:self.userFilePath error:nil];
    }
}

- (void)userLoginOut:(BOOL)clearViewControllers
{
    [self updateWithUser:nil];

    //移除除了设置和首页外的所有界面
    if (clearViewControllers) {
        @try {
            [self clearViewControllersToHomeAnimated:NO];
        }
        @catch (NSException *exception) {
//            NSLog(@"error---移除除了设置和首页外的所有界面---异常---%@",[MMAppDelegate.nav viewControllers]);
        }
        @finally {
            
        }
    }
//    NSMutableArray *array = [[MMAppDelegate.nav viewControllers] mutableCopy];
//    //两个Nav不是同一个，说明有mode层
//    [array removeObjectsInRange:NSMakeRange(nav != MMAppDelegate.nav ? 0 : 1, array.count - (nav != MMAppDelegate.nav ? 1 : 2))];
//    [MMAppDelegate.nav setViewControllers:array];
    //end
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoginStateChangeNotification object:nil];
}

/**
 *  清楚试图控制器堆栈，并返回到首页
 */
- (void)clearViewControllersToHomeAnimated:(BOOL)animated
{
    if (MMAppDelegate.rootNav != MMAppDelegate.nav) {
        [MMAppDelegate.nav dismissViewControllerAnimated:animated completion:NULL];
    }
    [MMAppDelegate.tabbarVC setSelectedIndex:0];
}

#pragma mark - 微关怀保存

- (NSString *)userCaringFilePath
{
    if (_userCaringFilePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        _userCaringFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[NSString stringWithFormat:@"%@|%@|UserCaring",self.currentAccountNumber,self.currentSerialNumber] stringFromMD5]];
    }
    return _userCaringFilePath;
}

- (NSMutableArray *)userCaringArrays
{
    if (_userCaringArrays == nil) {
        _userCaringArrays = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.userCaringFilePath] mutableCopy];
        if (_userCaringArrays == nil) {
            _userCaringArrays = [NSMutableArray array];
        }
    }
    return _userCaringArrays;
}

//添加新的用户关怀数据
- (void)addNewUserCaringWithObject:(DKUserCaringObject *)newObject
{
    if (newObject == nil || newObject.caringId == nil) {
        return;
    }
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"caringId", newObject.caringId];
    NSArray *results = [self.userCaringArrays filteredArrayUsingPredicate:predicateID];
    if (results && [results count] >= 1) {
        [self.userCaringArrays removeObject:[results firstObject]];
    }
    [self.userCaringArrays addObject:newObject];
    
    [self saveUserCaringData];
}

//得到对于的用户关怀数据，为空，说明没关怀过
- (DKUserCaringObject *)getUserCaringWithCaringId:(NSString *)caringId
{
    if (caringId == nil) {
        return nil;
    }
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"caringId", caringId];
    NSArray *results = [self.userCaringArrays filteredArrayUsingPredicate:predicateID];
    if (results && [results count] >= 1) {
        return [results firstObject];
    }
    return nil;
}

//保存用户关怀数据
- (void)saveUserCaringData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSKeyedArchiver archiveRootObject:self.userCaringArrays toFile:self.userCaringFilePath];
    });
}

@end
