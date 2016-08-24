//
//  DKHomeTableViewCell.m
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKHomeTableViewCell.h"
#import "DKHomeIndexData.h"
#import "MMAppDelegateHelper.h"

@interface DKHomeTableViewCell ()
{
    NSIndexPath *currentIndex;
}

@property (nonatomic, weak) IBOutlet UIImageView *ui_blImageView;

@property (nonatomic, weak) IBOutlet UIImageView *ui_iconImageView;

@property (nonatomic, weak) IBOutlet UILabel *ui_titleLabel;

/**
 *  icon
 */
@property (nonatomic, strong) NSArray *dataIcon;

@property (nonatomic, weak) IBOutlet UIButton *ui_bloodButton;

@property (weak, nonatomic) IBOutlet UIImageView *ui_starImage;

/**
 *  取值的数值
 */
@property (nonatomic, strong) NSArray *dataIndexFormat;

@end

@implementation DKHomeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DKHomeTableViewCell" owner:nil options:nil] lastObject];
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = MMRGBColor(244, 245, 246);
    
//    self.ui_blImageView.layer.masksToBounds = YES;
//    self.ui_blImageView.layer.cornerRadius = 7;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//iOS8 设置cell分隔条
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

#pragma mark - MMCellProtocol

- (void)setContentWithObject:(id)object AtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath;
    
    DKHomeIndexData *sportIndex = [object firstObject];
    NSString *valueKey = self.dataIndexFormat[indexPath.row];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    self.ui_titleLabel.text = [NSString stringWithFormat:@"%@",[sportIndex performSelector:NSSelectorFromString(valueKey)]];
#pragma clang diagnostic pop
    
    self.ui_iconImageView.image = [UIImage imageNamed:self.dataIcon[indexPath.row]];
    
    self.ui_bloodButton.hidden = (currentIndex.row != 3);
    
    //判断步数和睡眠有没有达到目标
    self.ui_starImage.hidden = YES;
    if (currentIndex.row == 0 || currentIndex.row == 2) {
        DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
        DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
        NSArray *arrays = [deviceInfo.target componentsSeparatedByString:@"#"];
        NSString *firstValue = [arrays firstObject]?:@"0";
        NSString *lastValue = [arrays lastObject]?:@"0";
        if (indexPath.row == 0 && [sportIndex.walk floatValue] - [firstValue floatValue] > 0.000001) {
            self.ui_starImage.hidden = NO;
        }
        if (indexPath.row == 2 && [sportIndex.allSleep floatValue] - [lastValue floatValue]*60 > 0.000001) {
            self.ui_starImage.hidden = NO;
        }
    }
}

- (IBAction)bloodButtonTaped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHomeBloodTaped_Sign object:nil];
}

- (BOOL)isDoubleChart
{
    return currentIndex.row == 2 || currentIndex.row == 3;
}

//根据给定的参数名，得到要取值的参数名数组
+ (NSArray *)doubleChartTypeParametersWithTypeParameter:(NSString *)typeParameter
{
    if ([typeParameter isEqualToString:@"blood"]) {
        return @[@"lblood",@"hblood"];
    }
    else if ([typeParameter isEqualToString:@"allSleep"]) {
        return @[@"lowSleep",@"sleep"];
    }
    return @[];
}

- (NSArray *)dataIndex
{
    if (_dataIndex == nil) {
        _dataIndex = @[@"walk", @"distance", @"allSleep" ,@"blood", @"heart", @"calorie", @"userRecord"];
    }
    return _dataIndex;
}

- (NSArray *)dataIndexFormat
{
    if (_dataIndexFormat == nil) {
        _dataIndexFormat = @[@"walkFormat", @"distanceFormat", @"allSleepFormat" ,@"bloodFormat", @"heartFormat", @"calorieFormat", @"userRecordFormat"];
    }
    return _dataIndexFormat;
}

- (NSArray *)dataIndexName
{
    if (_dataIndexName == nil) {
        _dataIndexName = @[@"步数", @"行走", @"睡眠" ,@"血压",@"心率", @"卡路里", @"个人记录"];
    }
    return _dataIndexName;
}

- (NSArray *)dataUnitName
{
    if (_dataUnitName == nil) {
        _dataUnitName = @[@"步", @"公里", @"小时" ,@"mmHg",@"次", @"卡路里", @"记录"];
    }
    return _dataUnitName;
}

- (NSArray *)dataIcon
{
    if (_dataIcon == nil) {
        _dataIcon = @[@"运动首页_14-26", @"运动首页_39", @"运动首页_39-54" ,@"bloodIcon",@"运动首页_56", @"运动首页_58", @"运动首页_60"];
    }
    return _dataIcon;
}

@end
