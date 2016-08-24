//
//  DKRegisterViewController.h
//  DataKit
//
//  Created by wangyangyang on 15/12/20.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "GeneralSuperViewController.h"

@interface DKRegisterViewController : GeneralSuperViewController

@property (nonatomic, assign) BOOL isLoginIn;

/**
 *  是否是找回密码
 */
@property (nonatomic, assign) BOOL isLookForPassword;

@end
