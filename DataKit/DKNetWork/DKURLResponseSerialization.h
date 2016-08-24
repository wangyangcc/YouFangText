//
//  DKURLResponseSerialization.h
//  DataKit
//
//  Created by wangyangyang on 15/12/10.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DKURLResponseSerialization <NSObject>

- (id)responseObjectForRequestParams:(NSDictionary *)requestParams
                          dataString:(NSString *)dataString
                               error:(NSError *__autoreleasing *)error;

@end

@interface DKSocketResponseSerialization : NSObject <DKURLResponseSerialization>

@end
