//
//  DKCaringObject.m
//  DataKit
//
//  Created by wangyangyang on 16/1/7.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "DKCaringObject.h"

@implementation DKCaringObject

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"caringId": @"msgid",
             
             @"caringName": @"msgname",
             
             @"picPath": @"picurl",
             
             };
}

@end
