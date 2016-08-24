//
//  DKDataDetailTableSectionView.m
//  DataKit
//
//  Created by wangyangyang on 16/1/8.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "DKDataDetailTableSectionView.h"

@implementation DKDataDetailTableSectionView
{
    UILabel *titleLabel;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(1, 12, 0, 50)];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title
{
    titleLabel.text = title;
}
@end
