//
//  DKDataDetailTableViewCell.m
//  DataKit
//
//  Created by wangyangyang on 16/1/8.
//  Copyright © 2016年 wang yangyang. All rights reserved.
//

#import "DKDataDetailTableViewCell.h"
#import "NSObject+dateFormat.h"

@implementation DKDataDetailTableViewCell
{
    UILabel *contentLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.textColor = [UIColor lightGrayColor];
        
        contentLabel = [UILabel new];
        contentLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:contentLabel];
        [contentLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(7, 70, 7, 20)];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title
                content:(NSString *)content
              titleType:(NSString *)titleType
            displayStar:(BOOL)displayStar
{
    self.textLabel.text = title;
    contentLabel.attributedText = [self labelContentWithValueStr:content titleType:titleType displayStar:displayStar];
}

- (NSMutableAttributedString *)labelContentWithValueStr:(NSString *)valueStr
                                              titleType:(NSString *)titleType
                                            displayStar:(BOOL)displayStar
{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    if (displayStar) {
        //积分图标
        UIImage *image = [UIImage imageNamed:@"star_small"];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, -3, 26, 26);
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        //end
    }
    
    NSString *firstString = [NSString stringWithFormat:@"%@%@",displayStar?@"  ":@"", valueStr?:@""];
    NSString *secondString = [NSString stringWithFormat:@"%@",titleType];
    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    
    [titleAttributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:27] range:NSMakeRange(0, firstString.length)];
    [titleAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(firstString.length, secondString.length)];
    
    [titleAttributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(52, 53, 54) range:NSMakeRange(0, firstString.length)];
    [titleAttributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(103, 104, 105) range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString appendAttributedString:titleAttributedString];
    
    return attributedString;
}

/**
 *  得到月日的格式化日期
 */
+ (NSString *)getMonthDayFormatDateWithDate:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"M月d日"];
    return [formatter stringFromDate:date];
}

/**
 *  得到用于cell显示的格式化时间
 */
+ (NSString *)getCellDisplayTitleDateWithDate:(NSDate *)date lookType:(DKDataDetailLookType)lookType
{
    if (date == nil) {
        return @"";
    }
    //说明是小时查看模式
    if (lookType < 0) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"MM月dd号 HH时"];
        return [formatter stringFromDate:date];
    }
    NSDate *todayDate = [NSObject toadyFormatDate];
    if ([todayDate compare:date] == NSOrderedSame) {
        return @"今天";
    }
    else if ([[NSObject yesterdayFormatDateWithDate:todayDate] compare:date] == NSOrderedSame)
    {
        return @"昨天";
    }
    else {
        if (lookType == DKDataDetailLookTypeWeek) {
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [formatter setDateFormat:@"MM-dd"];
            return [formatter stringFromDate:date];
        }
        else {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-hans"]];
            [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
            NSDateComponents *weekDateComp = [calendar components:NSWeekdayCalendarUnit fromDate:date];
            NSInteger weekDay = [weekDateComp weekday] - 1;
            return [@[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"] objectAtIndex:weekDay];
        }
    }
}

@end
