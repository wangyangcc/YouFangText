//
//  MMCheckAppUpdateHelper.h
//  Datakit
//
//  Created by wangyangyang on 15/7/14.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCheckAppUpdateHelper : NSObject

- (void)beginCheck;

/**
 *  得到帮助的网址
 */
- (NSString *)getHelpUrlPath;

/**
 *  得到关于的网址
 */
- (NSString *)getAboutUrlPath;

@end
