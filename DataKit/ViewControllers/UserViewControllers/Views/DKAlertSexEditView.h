//
//  DKAlertSexEditView.h
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKAlertSexEditView : UIView

@property (nonatomic, assign) NSInteger defaultSelectIndex;

@property (copy) void (^onButtonTouchUpInside)(DKAlertSexEditView *sexEditView, NSInteger buttonIndex);

@end
