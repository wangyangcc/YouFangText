//
//  DKEditDataViewController.h
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "GeneralSuperViewController.h"
#import "DKDeviceInfo.h"

@interface DKEditDataViewController : GeneralSuperViewController

/**
 *  要添加的设备信息
 */
@property (nonatomic, strong) DKDeviceInfo *deviceInfo;

/**
 *  是否是编辑模式
 */
@property (nonatomic, assign) BOOL isEditModel;

//是否绑定过
@property (nonatomic, assign) BOOL isBinded;

@end
