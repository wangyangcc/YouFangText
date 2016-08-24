//
//  DKCaringCollectionViewCell.m
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKCaringCollectionViewCell.h"
#import "DKCaringObject.h"
#import "MMAppDelegateHelper.h"
#import "NSObject+dateFormat.h"

@interface DKCaringCollectionViewCell ()
{
    NSString *todayTimeString;
    DKCaringObject *caringObject;
    
    DKUserCaringObject *userCaringObject;
}

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_bgLeadingConstraint;

@property (nonatomic, weak) IBOutlet UILabel *ui_titleLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_caringIconTopConstraint;

@property (nonatomic, weak) IBOutlet UIImageView *ui_caringIcon;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_caringLabelTopConstraint;

@property (nonatomic, weak) IBOutlet UILabel *ui_caringLabel;

@property (nonatomic, weak) IBOutlet UILabel *ui_caringTimeLabel;

/**
 *  提醒按钮 底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_caringButtonBottomConstraint;

/**
 *  互动次数 label 底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_caringNumberBottomConstraint;

/**
 *  互动指数 label 底部约束
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_interactionNumberBottomConstraint;

@property (nonatomic, strong) NSIndexPath *currentIndex;

@end

@implementation DKCaringCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    //设置圆角
    self.ui_caringLabel.layer.masksToBounds = YES;
    self.ui_caringLabel.layer.cornerRadius = 8.5; //圆角
    self.ui_caringLabel.layer.borderWidth = 1;
    self.ui_caringLabel.layer.borderColor = [MMRGBColor(194, 222, 132) CGColor];
    //end

}

#pragma mark - event 

- (IBAction)remindButtonTaped
{
    [self performSelector:@selector(doCaring) withObject:nil afterDelay:0.1];
}

- (void)doCaring
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.c_delegate remindButtonTaped:self.currentIndex];
    //更新本地数据
    if (userCaringObject == nil) {
        userCaringObject = [DKUserCaringObject new];
        userCaringObject.caringId = caringObject.caringId;
        userCaringObject.caringNumber = @"0";
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    if ((NSInteger)ScreenWidth > 320) {
        [formatter setDateFormat:@"yyyy年M月d日"];
    }
    else {
        [formatter setDateFormat:@"yy年M月d日"];
    }
    userCaringObject.caringDate = [formatter stringFromDate:[NSDate dk_date]];
    userCaringObject.caringNumber = [@([userCaringObject.caringNumber integerValue]+1) stringValue];
    [[MMAppDelegateHelper shareHelper] addNewUserCaringWithObject:userCaringObject];
    //end
}

#pragma mark - method

- (NSMutableAttributedString *)titleLabelWithPropertyName:(NSString *)propertyName
                                             propertyTime:(NSString *)propertyTime
{
    NSString *firstString = [NSString stringWithFormat:@"%@\n",propertyName];
    NSString *secondString = [NSString stringWithFormat:@"%@",propertyTime];

    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(147, 141, 37) range:NSMakeRange(0, allString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, firstString.length)];

    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:NSMakeRange(firstString.length, secondString.length)];
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.paragraphSpacing = 5;
    parStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

- (void)setContentWithObject:(id)object AtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath;
    caringObject = [object objectAtIndex:indexPath.row];
    self.ui_titleLabel.text = caringObject.caringName;
    [self.ui_caringIcon setImageWithURL:[NSURL URLWithString:caringObject.picPath] placeholderImage:nil];
    
    self.ui_caringIconTopConstraint.constant = [MetaData valueForDeviceCun3_5:14 cun4:17 cun4_7:24 cun5_5:30];
    self.ui_caringLabelTopConstraint.constant = [MetaData valueForDeviceCun3_5:78 cun4:80 cun4_7:93 cun5_5:103];
    self.ui_caringButtonBottomConstraint.constant = [MetaData valueForDeviceCun3_5:70 cun4:73 cun4_7:84 cun5_5:93];
    self.ui_caringNumberBottomConstraint.constant = [MetaData valueForDeviceCun3_5:35 cun4:37 cun4_7:42 cun5_5:46];
    self.ui_interactionNumberBottomConstraint.constant = [MetaData valueForDeviceCun3_5:8 cun4:10 cun4_7:12 cun5_5:15];
    
    //判断是否关怀过
    userCaringObject = [[MMAppDelegateHelper shareHelper] getUserCaringWithCaringId:caringObject.caringId];
    if (userCaringObject) {
        self.ui_caringLabel.text = [NSString stringWithFormat:@"%ld次",(long)[userCaringObject.caringNumber integerValue]];
        self.ui_caringTimeLabel.text = userCaringObject.caringDate;
    }
    else {
        self.ui_caringLabel.text = @"尚未关怀";
        self.ui_caringTimeLabel.text = @"无";
    }
    //end
}

@end
