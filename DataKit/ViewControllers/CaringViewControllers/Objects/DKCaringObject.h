//
//  DKCaringObject.h
//  DataKit
//
//  Created by wangyangyang on 16/1/7.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKCaringObject : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *caringId;

@property (nonatomic, copy) NSString *caringName;

@property (nonatomic, copy) NSString *picPath;

@property (nonatomic, strong) NSNumber *total;

@property (nonatomic, copy) NSString *lastdate;

@property (nonatomic, copy) NSString *lastdateFormatter;

@end
