//
//  MMScrollViewObjectProtocol.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/7.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef XinHuaPublish_MMScrollViewObjectProtocol_h
#define XinHuaPublish_MMScrollViewObjectProtocol_h

@protocol MMScrollViewObjectProtocol <NSObject>

@property (copy, nonatomic) NSString *s_id;
@property (copy, nonatomic) NSString *s_titleWidth;
@property (copy, nonatomic) NSString *s_title;
@property (copy, nonatomic) NSString *s_keyString;
//枚举类型
@property (copy, nonatomic) NSString *s_vcType;

@property (copy, nonatomic) NSString *s_normalImage;
@property (copy, nonatomic) NSString *s_selectImage;

@end

#endif
