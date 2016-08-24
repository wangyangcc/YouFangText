//
//  DKUserRecordTableViewCell.m
//  DataKit
//
//  Created by wangyangyang on 15/12/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUserRecordTableViewCell.h"
#import "DKUserRecordData.h"

@interface DKUserRecordTableViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *ui_iconImage;

@property (nonatomic, strong) IBOutlet UILabel *ui_titleLabel;

@property (nonatomic, strong) IBOutlet UILabel *ui_valueLabel;

/**
 *  取值的数值
 */
@property (nonatomic, strong) NSArray *dataIndex;

/**
 *  取值的数值 名称
 */
@property (nonatomic, strong) NSArray *dataTitle;

/**
 *  icon
 */
@property (nonatomic, strong) NSArray *dataIcon;

@end

@implementation DKUserRecordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DKUserRecordTableViewCell" owner:nil options:nil] lastObject];
    return self;
}

- (void)awakeFromNib {
    // Initialization code
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DKUserRecordData *sportIndex = [object firstObject];
    NSString *valueKey = self.dataIndex[indexPath.row];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *selString = [NSString stringWithFormat:@"%@AttributedString",valueKey];
    self.ui_valueLabel.attributedText = [sportIndex performSelector:NSSelectorFromString(selString)];
#pragma clang diagnostic pop
    
    self.ui_titleLabel.text = self.dataTitle[indexPath.row];
    self.ui_iconImage.image = [UIImage imageNamed:self.dataIcon[indexPath.row]];
}

- (NSArray *)dataIndex
{
    if (_dataIndex == nil) {
        _dataIndex = @[@"walk", @"distance", @"calorie", @"allSleep", @"sleep"];
    }
    return _dataIndex;
}

- (NSArray *)dataIcon
{
    if (_dataIcon == nil) {
        _dataIcon = @[@"icon1", @"icon6", @"icon4", @"icon2", @"icon3"];
    }
    return _dataIcon;
}

- (NSArray *)dataTitle
{
    if (_dataTitle == nil) {
        _dataTitle = @[@"最大步数", @"最大运行距离", @"最大卡路里值" , @"最长睡眠", @"最长深睡眠"];
    }
    return _dataTitle;
}

@end
