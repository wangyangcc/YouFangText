//
//  DKAccountSwitchViewController.h
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "GeneralSuperViewController.h"
#import "MGSwipeTableCell.h"

@interface DKAccountSwitchViewController : GeneralSuperViewController

@end

@interface DKAccountSwitchTableViewCell : MGSwipeTableCell

@property (nonatomic, assign) BOOL isSmallImage;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;

@end
