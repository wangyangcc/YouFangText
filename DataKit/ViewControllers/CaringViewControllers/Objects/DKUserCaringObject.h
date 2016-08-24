//
//  DKUserCaringObject.h
//  DataKit
//
//  Created by wangyangyang on 16/3/29.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "MTLModel.h"

@interface DKUserCaringObject : MTLModel

//关怀的id
@property (nonatomic, copy) NSString *caringId;

//关怀次数
@property (nonatomic, copy) NSString *caringNumber;

//关怀的时间
@property (nonatomic, copy) NSString *caringDate;

@end
