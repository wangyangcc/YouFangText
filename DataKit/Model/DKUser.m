//
//  DKUser.m
//  DataKit
//
//  Created by wangyangyang on 15/12/10.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUser.h"
#import "DKDeviceInfo.h"

@implementation DKUser

//代理方法，返回本类属性和字典取值属性相对应的关系
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"userId": @"account",
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    // Store a value that needs to be determined locally upon initialization.
    
    //用户的终端列表
    if ([[dictionaryValue allKeys] containsObject:@"terminals"]) {
        NSArray *array = [dictionaryValue objectForKey:@"terminals"];
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count + 1];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[DKDeviceInfo class]] == NO) {
                NSError *error = nil;
                MTLModel *model = [MTLJSONAdapter modelOfClass:NSClassFromString(@"DKDeviceInfo") fromJSONDictionary:obj error:&error];
                [newArray addObject:model];
            }
            else {
                [newArray addObject:obj];
            }
        }];
        self.terminals = newArray;
    }
    //end
    
    return self;
}


/**
 *  得到当前选择的手表设备信息
 */
- (DKDeviceInfo *)getSelectedDeviceInfo
{
    if (self.selectedSerialNumber == nil || [self.selectedSerialNumber length] == 0 || self.terminals == nil || [self.terminals count] == 0) {
        return nil;
    }
    NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"serialNumber", self.selectedSerialNumber];
    NSArray *results = [self.terminals filteredArrayUsingPredicate:predicateID];
    if (results && [results count] >= 1) {
        return [results firstObject];
    }
    return nil;
}

@end
