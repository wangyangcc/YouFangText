//
//  HomeCenterViewController.h
//  TestNav
//
//  Created by lcc on 13-11-29.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface HomeCenterViewController : UIViewController

@property (nonatomic, strong) SuperViewController *leftVC;
@property (nonatomic, strong) SuperViewController *rightVC;
@property (nonatomic, strong) NSString *centerVCString;
@property (nonatomic) BOOL leftVcHidden;//默认显示 YES不显示
@property (nonatomic) BOOL rightVcHidden;//默认显示 YES不显示
@property (nonatomic) BOOL centerIsTop;//默认不顶上

//menu单击没有添加
- (void) leftMenuTapped:(UIButton *) sender;
- (void) rightMenuTapped:(UIButton *) sender;

- (void) setCenterViewControllerWithString:(NSString *) VCString object:(id) object;

@end
