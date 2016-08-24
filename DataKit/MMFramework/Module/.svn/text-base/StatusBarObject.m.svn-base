//
//  StatusBarObject.m
//  SanMen
//
//  Created by lcc on 14-1-1.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import "StatusBarObject.h"

@implementation StatusBarObject

/**
 *  缓存模式状态
 *
 *  @return 是否是缓存模式
 */
+ (BOOL) getCacheStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"MMCacheStatusYanshi"];
}

/**
 *   更新缓存状态
 */
+ (void) updateCacheStatus:(BOOL)isUse
{
    if (isUse == NO) {
        [NSURLProtocol unregisterClass:NSClassFromString(@"RNCachingURLProtocol")];
    }
    else {
        [NSURLProtocol registerClass:NSClassFromString(@"RNCachingURLProtocol")];
    }
    [[NSUserDefaults standardUserDefaults] setBool:isUse forKey:@"MMCacheStatusYanshi"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
