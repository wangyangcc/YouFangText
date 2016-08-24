//
//  DKUserImageView.m
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUserImageView.h"
#import "MMAppDelegateHelper.h"

@implementation DKUserImageView
{
    UIImageView *photoView;
    __weak id<NSObject> notificationOne;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:notificationOne];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_nav_icon"]];
        icon.frame = CGRectMake(5, (44 - 28)/2, 12, 28);
        [self addSubview:icon];
        
        photoView = [UIImageView new];
        photoView.backgroundColor = [UIColor whiteColor];
        photoView.layer.masksToBounds = YES;
        photoView.frame = CGRectMake(20, 7, 30, 30);
        [self addSubview:photoView];
        [self updatePhotoCornerRadius:15];
        
        [self updatePhotoImage];
        
        //用户选择设备改变通知，更新用户头像
        notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self updatePhotoImage];
        }];
        //end
        
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped)];
        [self addGestureRecognizer:tap];
        //end
    }
    return self;
}

- (void)updatePhotoImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
        if (user) {
            DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
            [photoView setImageWithURL:[NSURL URLWithString:deviceInfo.photoPath] placeholderImage:[UIImage imageNamed:deviceInfo.sex == 1 ? @"user_default_woman" : @"user_default_man"]];
        }
        else {
            photoView.image = [UIImage imageNamed:@"user_default"];
        }
    });
}

- (void)updatePhotoCornerRadius:(CGFloat)cornerRadius
{
    photoView.layer.cornerRadius = cornerRadius; //圆角
}

- (void)taped
{
    [MMAppDelegate.nav pushViewController:[NSClassFromString(@"DKAccountSwitchViewController") new]];
}

@end
