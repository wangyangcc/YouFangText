//
//  DataCompareObject.h
//  SanMen
//
//  Created by lcc on 14-1-13.
//  Copyright (c) 2014年 lcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCompareObject : NSObject

+ (int)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay;

+ (NSString *) getCurrentTimeWithFormate:(NSString *) formateString;

@end
