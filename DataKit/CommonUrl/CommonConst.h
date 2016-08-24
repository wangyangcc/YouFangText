//
//  CommonConst.h
//  Datakit
//
//  Created by wangyangyang on 15/5/26.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef YouAsk_CommonConst_h
#define YouAsk_CommonConst_h

//-----------------------------------    通知常用配置   -------------------------------

static NSString * const UMShareToWechatSession = @"UMShareToWechatSession";

static NSString * const UMShareToWechatTimeline = @"UMShareToWechatTimeline";

static NSString * const UMShareToQQ = @"UMShareToQQ";


static NSString * const kSocketRequestMethodPort = @"kSocketRequestMethodPort";
static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";

//用户登录状态改变
static NSString * const kUserLoginStateChangeNotification = @"kUserLoginStateChangeNotification";

//首页数据更新
static NSString * const kHomeVCUpdateDataNotification = @"kHomeVCUpdateDataNotification";

//用户选择设备改变通知
static NSString * const kUserSelectedDeviceChangeNotification = @"kUserSelectedDeviceChangeNotification";

//综合指数底部数据刷新
static NSString * const kCompositeIndexBottomDataChangeNotification = @"kCompositeIndexBottomDataChangeNotification";

/**
 *  保存到本地的唯一区别码
 */
static NSString* kResponseModel_LocalSaveId_Sign = @"kResponseModel_LocalSaveId_Sign";

/**
 *  首页点击血压事件
 */
static NSString* kHomeBloodTaped_Sign = @"kHomeBloodTaped_Sign";

/**
 *  首页点击血压事件，更新微关怀界面
 */
static NSString* kHomeBloodUpdateCaringVC_Sign = @"kHomeBloodUpdateCaringVC_Sign";

#endif
