//
//  NSDictionary+Extras.h
//  Datakit
//
//  Created by wangyangyang on 15/7/21.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extras)

- (NSString*)stringFromURLEncodedQueryParams;

- (NSString*)stringFromQueryParams;

@end
