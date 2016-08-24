//
//  MMViewProtocol.h
//  Datakit
//
//  Created by wangyangyang on 15/6/1.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMViewProtocol <NSObject>

/**
 *  根据数据得到试图高度
 *
 *  @param data 数据
 *
 *  @return 高度
 */
+ (CGFloat)getViewHeightWithData:(id)data;

@end
