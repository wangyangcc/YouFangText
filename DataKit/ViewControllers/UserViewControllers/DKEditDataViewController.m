//
//  DKEditDataViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKEditDataViewController.h"
#import "ZHRulerView.h"
#import "DKDataMultipleSelectionView.h"
#import "MMAppDelegateHelper.h"
#import "NSString+URLEncoding.h"

static NSString * const kHeightButtonValue = @"height"; /**< 身高 */
static NSString * const kWeightButtonValue = @"weight"; /**< 体重 */
static NSString * const kBirthdayButtonValue = @"birthday"; /**< 生日 */
static NSString * const kBloodPressureButtonValue = @"bloodpressure"; /**< 血压 */
static NSString * const kBloodSugarButtonValue = @"BloodSugar"; /**< 血糖 */

@interface DKEditDataViewController () <ZHRulerViewDelegate>
{
    CGFloat contentViewHeight; /**< scrollview内容view的高度 */
    
    BOOL isUpdate;
}

/**
 *  背部滑动试图
 */
@property (weak, nonatomic) IBOutlet UIScrollView *ui_scrollView;

/**
 *  内容试图
 */
@property (weak, nonatomic) IBOutlet UIView *ui_contentView;

/**
 *  内容试图高度
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_contentViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UILabel *ui_userNameLabel;

@property (nonatomic, weak) IBOutlet UIView *ui_editLabelSuperView; /**< 各种编辑label的父试图 */

@property (nonatomic, strong) NSMutableDictionary *editDataDictionary; /**< 作为编辑数据的载体 */

@property (nonatomic, weak) IBOutlet UIButton *ui_nextButton; /**< 下一步按钮 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ui_nextButtonTopConstraint; /**< 下一步按钮顶部约束 */

@property (nonatomic,strong) ZHRulerView *co_rulerview;
@property (nonatomic,strong) UILabel *co_rulerLabel;

@property (nonatomic, strong) UIDatePicker *co_datePicker;
@property (nonatomic, strong) DKDataMultipleSelectionView *co_multipleSelectionView;

@property (nonatomic, strong) DKClientRequest *clientRequest;

@end

@implementation DKEditDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.deviceInfo = [DKDeviceInfo new];
    
    [self updateViewStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.ui_scrollView.contentSize = CGSizeMake(ScreenWidth, contentViewHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.deviceInfo.relation) {
        self.ui_userNameLabel.text = [NSString stringWithFormat:@"%@的资料",self.deviceInfo.relation];
    }
    else {
        self.ui_userNameLabel.text = @"TA的资料";
    }
    
    MMAppDelegate.nav.isSlider = NO;
    
    if (isUpdate == NO) {
        [self updateViewWhenAppear];
        isUpdate = YES;
    }
}

#pragma mark - custom method

- (void)updateViewStyle
{
    self.ui_contentView.backgroundColor = [UIColor whiteColor];
    //设置导航条
    self.customeNavBarView.m_navTitleLabel.text = @"设置";
    //end
    
    //设置label可点击
    for (NSInteger index = 0; index < 5; index ++) {
        UILabel *label = [self.ui_editLabelSuperView viewWithTag:100 + index];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editLabelTaped:)];
        [label addGestureRecognizer:tap];
    }
    //end
    
    //设置滑动试图内容高度
    contentViewHeight = MAX(644, ScreenHeight + 5);
    self.ui_contentViewHeightConstraint.constant = contentViewHeight;
    //end
    
    //iphone 6 以后机型，不可滑动，之前可滑动
    //iphone 6 以前机型，上移下一步按钮，让用户可看到
    if (ScreenWidth > 320) {
        self.ui_scrollView.scrollEnabled = NO;
        self.ui_nextButtonTopConstraint.constant = 200;
    }
    else {
        self.ui_scrollView.scrollEnabled = YES;
        self.ui_nextButtonTopConstraint.constant = [MetaData isIphone4_4s] ? 25 : 110;
    }
    //end
}

/**
 *  试图显示出来的时候刷新
 */
- (void)updateViewWhenAppear
{

    //转换data
    if (self.isEditModel) {
        [self.editDataDictionary setValue:[NSString stringWithFormat:@"%@",self.deviceInfo.height] forKey:kHeightButtonValue];
        [self.editDataDictionary setValue:[NSString stringWithFormat:@"%@",self.deviceInfo.weight] forKey:kWeightButtonValue];
        [self.editDataDictionary setValue:self.deviceInfo.birthday?:@"00-00-00" forKey:kBirthdayButtonValue];
        [self.editDataDictionary setValue:self.deviceInfo.bloodPressure?:@"" forKey:kBloodPressureButtonValue];
        [self.editDataDictionary setValue:self.deviceInfo.bloodSugar?:@"" forKey:kBloodSugarButtonValue];
    }
    else {
        [self.editDataDictionary setValue:@"168" forKey:kHeightButtonValue];
        [self.editDataDictionary setValue:@"--" forKey:kWeightButtonValue];
        [self.editDataDictionary setValue:@"00-00-00" forKey:kBirthdayButtonValue];
        [self.editDataDictionary setValue:@"正常" forKey:kBloodPressureButtonValue];
        [self.editDataDictionary setValue:@"正常" forKey:kBloodSugarButtonValue];
    }
    //end
    
    [self updateViewWhenEdit];
}

/**
 *  编辑的时候更新view
 */
- (void)updateViewWhenEdit
{

    NSArray *valueArray = @[kHeightButtonValue,kWeightButtonValue, kBirthdayButtonValue, kBloodPressureButtonValue, kBloodSugarButtonValue];
    for (NSInteger index = 0; index < [valueArray count]; index ++) {
        UILabel *label = (UILabel *)[self.ui_editLabelSuperView viewWithTag:100 + index];
        NSString *currentValue = self.editDataDictionary[valueArray[index]];
//        if (currentValue == nil || [currentValue isEqualToString:@"(null)"]) {
//            [self.editDataDictionary setValue:@"" forKey:valueArray[index]];
//            currentValue = @"";
//        }
        if (index < 3) {
            label.attributedText = [self multicolourLabelWithPropertyKey:valueArray[index] propertyValue:currentValue];
        }
        else {
            label.attributedText = [self normolLabelWithPropertyKey:valueArray[index] propertyValue:currentValue];
        }
    }
    [self updateNextButtonState];
}

/**
 *  更新下一步按钮状态
 */
- (void)updateNextButtonState
{
    if ([self.editDataDictionary[kWeightButtonValue] isEqualToString:@"--"] == NO && [self.editDataDictionary[kBirthdayButtonValue] isEqualToString:@"00-00-00"] == NO) {
        self.ui_nextButton.enabled = YES;
    }
    else {
        self.ui_nextButton.enabled = NO;
    }
}

/**
 *  前三个 身高 体重 生日 内容生成
 *
 */
- (NSMutableAttributedString *)multicolourLabelWithPropertyKey:(nullable NSString *)propertyKey
                                                  propertyValue:(nullable NSString *)propertyValue
{
    NSString *firstString = [NSString stringWithFormat:@"%@",propertyValue];
    NSString *secondString = @"";
    if ([propertyKey isEqualToString:kHeightButtonValue]) {
        secondString = @" cm";
    }
    if ([propertyKey isEqualToString:kWeightButtonValue]) {
        secondString = @" kg";
    }
    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(33, 172, 236) range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(0, 0, 0) range:NSMakeRange(firstString.length, secondString.length)];
    
    //图标
    UIImage *image = [UIImage imageNamed:@"edit_down"];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    //end
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.alignment = NSTextAlignmentRight;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

/**
 *  前三个 身高 体重 生日 内容生成
 *
 */
- (NSMutableAttributedString *)normolLabelWithPropertyKey:(nullable NSString *)propertyKey
                                            propertyValue:(nullable NSString *)propertyValue
{
    NSString *firstString = [NSString stringWithFormat:@"%@",propertyValue];

    NSString *allString = [NSString stringWithFormat:@"%@    ",firstString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(70, 71, 72) range:NSMakeRange(0, firstString.length)];
    
    //图标
    UIImage *image = [UIImage imageNamed:@"edit_down"];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    //end
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.alignment = NSTextAlignmentRight;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

/**
 *  标尺label
 *
 */
- (NSMutableAttributedString *)rulerLabelWithPropertyKey:(nullable NSString *)propertyKey
                                           propertyValue:(nullable NSString *)propertyValue
{
    NSString *firstString = [NSString stringWithFormat:@"%@",propertyValue];
    NSString *secondString = @"";
    if ([propertyKey isEqualToString:kHeightButtonValue]) {
        secondString = @" cm";
    }
    if ([propertyKey isEqualToString:kWeightButtonValue]) {
        secondString = @" kg";
    }
    NSString *allString = [NSString stringWithFormat:@"%@%@",firstString,secondString];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:allString];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, firstString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(33, 172, 236) range:NSMakeRange(0, firstString.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(firstString.length, secondString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:MMRGBColor(50, 51, 52) range:NSMakeRange(firstString.length, secondString.length)];
    
    NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    parStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parStyle range:NSMakeRange(0, allString.length)];
    return attributedString;
}

#pragma mark - rulerviewDelagete

- (void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    self.co_rulerLabel.attributedText = [self rulerLabelWithPropertyKey:rulerView.typeValue propertyValue:[NSString stringWithFormat:@"%d",(int)rulerValue]];
    //刷新界面
    [self.editDataDictionary setValue:[NSString stringWithFormat:@"%d",(int)rulerValue] forKey:rulerView.typeValue];
    [self updateViewWhenEdit];
    //end
}

#pragma mark - event

- (void)editLabelTaped:(UITapGestureRecognizer *)tap
{
    NSInteger tagIndex = tap.view.tag - 100;
    
    //如果是iphone 6以前机型，移动下一步按钮
    if ((int)ScreenWidth <= 320) {
        if (self.ui_nextButtonTopConstraint.constant != 200) {
            self.ui_nextButtonTopConstraint.constant = 200;
            [self.view setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.35 animations:^{
                [self.view setNeedsLayout];
            }];
        }
        //170
        [self.ui_scrollView setContentOffset:CGPointMake(0, [MetaData isIphone4_4s]? (tagIndex >= 2 ? 170 : 64) : 64) animated:YES];
    }
    //end
    
    switch (tagIndex) {
        case 0: {//身高
            //移除其他可能有的编辑选项
            if (self.co_datePicker) {
                [self.co_datePicker removeFromSuperview];
                self.co_datePicker = nil;
            }
            if (self.co_multipleSelectionView) {
                [self.co_multipleSelectionView removeFromSuperview];
                self.co_multipleSelectionView = nil;
            }
            //end
            NSString *value = [self.editDataDictionary valueForKey:kHeightButtonValue];
            [self showRulerViewWithDefaultValue:value typeValue:kHeightButtonValue];
            break;
        }
        case 1: {//体重
            //移除其他可能有的编辑选项
            if (self.co_datePicker) {
                [self.co_datePicker removeFromSuperview];
                self.co_datePicker = nil;
            }
            if (self.co_multipleSelectionView) {
                [self.co_multipleSelectionView removeFromSuperview];
                self.co_multipleSelectionView = nil;
            }
            //end
            NSString *value = [self.editDataDictionary valueForKey:kWeightButtonValue];
            if ([value isEqualToString:@"--"]) {
                value = nil;
            }
            [self showRulerViewWithDefaultValue:value typeValue:kWeightButtonValue];
            break;
        }
        case 2: {//生日
            //移除其他可能有的编辑选项
            if (self.co_rulerLabel) {
                [self.co_rulerLabel removeFromSuperview];
                [self.co_rulerview removeFromSuperview];
                self.co_rulerLabel = nil;
                self.co_rulerview = nil;
            }
            if (self.co_multipleSelectionView) {
                [self.co_multipleSelectionView removeFromSuperview];
                self.co_multipleSelectionView = nil;
            }
            //end
            NSString *value = [self.editDataDictionary valueForKey:kBirthdayButtonValue];
            //如果不是默认值，则设置
            if ([value isEqualToString:@"00-00-00"] == NO) {
                NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
                dateFmt.dateFormat = @"yyyy-MM-dd";
                [self.co_datePicker setDate:[dateFmt dateFromString:value] animated:NO];
            }
            //end
            [self.ui_contentView addSubview:self.co_datePicker];
            self.co_datePicker.frame = CGRectMake(50, CGRectGetMaxY(self.ui_editLabelSuperView.frame) + 50, ScreenWidth - 100, 100);
            break;
        }
        case 3: //血压
            //移除其他可能有的编辑选项
            if (self.co_rulerLabel) {
                [self.co_rulerLabel removeFromSuperview];
                [self.co_rulerview removeFromSuperview];
                self.co_rulerLabel = nil;
                self.co_rulerview = nil;
            }
            if (self.co_datePicker) {
                [self.co_datePicker removeFromSuperview];
                self.co_datePicker = nil;
            }
            if (self.co_multipleSelectionView && [self.co_multipleSelectionView.tagSelection isEqualToString:kBloodSugarButtonValue]) {
                [self.co_multipleSelectionView removeFromSuperview];
                self.co_multipleSelectionView = nil;
            }
            //end
            [self showMultipleSelectionViewWithTypeValue:kBloodPressureButtonValue];
            break;
        case 4: //血糖
            //移除其他可能有的编辑选项
            if (self.co_rulerLabel) {
                [self.co_rulerLabel removeFromSuperview];
                [self.co_rulerview removeFromSuperview];
                self.co_rulerLabel = nil;
                self.co_rulerview = nil;
            }
            if (self.co_datePicker) {
                [self.co_datePicker removeFromSuperview];
                self.co_datePicker = nil;
            }
            if (self.co_multipleSelectionView && [self.co_multipleSelectionView.tagSelection isEqualToString:kBloodPressureButtonValue]) {
                [self.co_multipleSelectionView removeFromSuperview];
                self.co_multipleSelectionView = nil;
            }
            //end
            [self showMultipleSelectionViewWithTypeValue:kBloodSugarButtonValue];
            break;
        default:
            break;
    }
}

- (IBAction)nextTaped:(id)sender
{
//    if ([self.ui_textField.text length] <= 0) {
//        [SVProgressHUD showInfoWithStatus:@"输入使用者和您的关系"];
//        return;
//    }
    //转换数据
    self.deviceInfo.height = self.editDataDictionary[kHeightButtonValue];
    self.deviceInfo.weight = self.editDataDictionary[kWeightButtonValue];
    self.deviceInfo.bloodPressure = self.editDataDictionary[kBloodPressureButtonValue];
    self.deviceInfo.bloodSugar = self.editDataDictionary[kBloodSugarButtonValue];
    //end
    [SVProgressHUD show];
    [self setUserInteractionEnabled:NO];
    if (self.isEditModel && self.isBinded == NO) {
        [self.clientRequest editDeviceWithInfo:self.deviceInfo];
    }
    else {
        [self.clientRequest addNewDeviceWithInfo:self.deviceInfo];
    }
}

- (void)datePickerChange:(UIDatePicker *)datePicker
{
    NSDate *currentDate = datePicker.date;
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd";
    NSString *dateFmtString = [dateFmt stringFromDate:currentDate];
    
    //设置参数需要的值
    dateFmt.dateFormat = @"yyyy-MM-dd";
    self.deviceInfo.birthday = [dateFmt stringFromDate:currentDate];
    //end
    
    //刷新界面
    [self.editDataDictionary setValue:dateFmtString forKey:kBirthdayButtonValue];
    [self updateViewWhenEdit];
    //end
}

/**
 *  显示刻度尺
 *
 *  @param defaultValue 默认数值
 *  @param typeValue    类型，身高，还是体重
 */
- (void)showRulerViewWithDefaultValue:(NSString *)defaultValue
                            typeValue:(NSString *)typeValue
{
    if (self.co_rulerview) {
        [self.co_rulerview removeFromSuperview];
    }
    ZHRulerView *rulerview = nil;
    if ([typeValue isEqualToString:kHeightButtonValue]) {
        rulerview = [[ZHRulerView alloc] initWithMixNuber:120 maxNuber:230 showType:rulerViewshowHorizontalType rulerMultiple:10];
        rulerview.defaultVaule = [defaultValue integerValue];
    }
    else if ([typeValue isEqualToString:kWeightButtonValue]) {
        rulerview = [[ZHRulerView alloc] initWithMixNuber:25 maxNuber:205 showType:rulerViewshowHorizontalType rulerMultiple:10];
        rulerview.defaultVaule = defaultValue?[defaultValue integerValue]:60;
    }
    [rulerview logOnDealloc];
    rulerview.backgroundColor = MMRGBColor(245, 246, 247);
    rulerview.round = YES;
    rulerview.delegate = self;
    rulerview.typeValue = typeValue;
    self.co_rulerview = rulerview;
    rulerview.frame = CGRectMake(50, CGRectGetMaxY(self.ui_editLabelSuperView.frame) + 75, ScreenWidth - 100, 60);
    [self.ui_contentView addSubview:rulerview];
    
    //设置文本
    if (self.co_rulerLabel) {
        [self.co_rulerLabel removeFromSuperview];
    }
    self.co_rulerLabel.frame = CGRectMake(50, CGRectGetMaxY(self.ui_editLabelSuperView.frame) + 23, ScreenWidth - 100, 40);
    [self.ui_contentView addSubview:self.co_rulerLabel];
    self.co_rulerLabel.attributedText = [self rulerLabelWithPropertyKey:typeValue propertyValue:[NSString stringWithFormat:@"%d",(int)rulerview.defaultVaule]];
    //end
}

/**
 *  显示血压和血糖选项
 *
 *  @param typeValue 类型
 */
- (void)showMultipleSelectionViewWithTypeValue:(NSString *)typeValue
{
    UIView *tagLabel = [self.ui_editLabelSuperView viewWithTag:[typeValue isEqualToString:kBloodPressureButtonValue] ? 103: 104];
    //判断是否重复显示
    if (_co_multipleSelectionView && _co_multipleSelectionView.tag == tagLabel.tag + 300) {
        return;
    }
    //end
    //添加血压和血糖的选择
    self.co_multipleSelectionView = [[DKDataMultipleSelectionView alloc] initWithFrame:CGRectZero];
    [self.ui_contentView addSubview:self.co_multipleSelectionView];
    self.co_multipleSelectionView.tag = tagLabel.tag + 300;
    self.co_multipleSelectionView.tagSelection = typeValue;
    
    __weak typeof(self) weakSelf = self;
    [self.co_multipleSelectionView setOnButtonTouchUpInside:^(DKDataMultipleSelectionView *view, NSString *buttonMark) {
        [view hideWithCompletion:^(BOOL finished) {
            //刷新界面
            [weakSelf.editDataDictionary setValue:buttonMark forKey:view.tagSelection];
            [weakSelf.co_multipleSelectionView removeFromSuperview];
            weakSelf.co_multipleSelectionView = nil;
            [weakSelf updateViewWhenEdit];
            //end
        }];
    }];
    [self.co_multipleSelectionView autoSetDimension:ALDimensionHeight toSize:kDataMultipleSelectionContentHeight];
    [self.co_multipleSelectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:tagLabel];
    [self.co_multipleSelectionView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:tagLabel];
    [self.co_multipleSelectionView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:tagLabel];
    [self.co_multipleSelectionView show];
    [self.co_multipleSelectionView logOnDealloc];
    //end
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    [self setUserInteractionEnabled:YES];
    DKDeviceInfo *deviceInfo = [clientRequest.responseObject firstObject];
    //判断是否成功
    if (deviceInfo.isSuccess == NO) {
        [SVProgressHUD showInfoWithStatus:[DKClientRequest errorCodeDic][deviceInfo.errorCode]];
        return;
    }
    DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
    NSMutableArray *newTerminals = [NSMutableArray array];
    if (user.terminals) {
        [newTerminals addObjectsFromArray:user.terminals];
        //判断是否是编辑模式，是则删除本地相同的
        if (self.isEditModel) {
            NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"%K == %@",@"serialNumber", self.deviceInfo.serialNumber];
            NSArray *results = [newTerminals filteredArrayUsingPredicate:predicateID];
            if (results && [results count] >= 1) {
                [newTerminals removeObject:[results firstObject]];
            }
        }
        //end
    }
    [newTerminals insertObject:deviceInfo atIndex:0];
    user.terminals = newTerminals;
    [[MMAppDelegateHelper shareHelper] updateWithUser:user];
    [SVProgressHUD showSuccessWithStatus:self.isEditModel?@"修改成功":@"添加成功"];
    [MMAppDelegate.nav dismissViewControllerAnimated:YES completion:NULL];
    //end
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    [self setUserInteractionEnabled:YES];
    [SVProgressHUD showErrorWithStatus:@"请稍后重试"];
}

#pragma mark - getters and setters

- (NSMutableDictionary *)editDataDictionary
{
    if (_editDataDictionary == nil) {
        _editDataDictionary = [NSMutableDictionary dictionary];
    }
    return _editDataDictionary;
}

- (UILabel *)co_rulerLabel
{
    if (_co_rulerLabel == nil) {
        _co_rulerLabel = [UILabel new];
        _co_rulerLabel.backgroundColor = [UIColor whiteColor];
    }
    return _co_rulerLabel;
}

- (UIDatePicker *)co_datePicker
{
    if (_co_datePicker == nil) {
        _co_datePicker = [[UIDatePicker alloc] init];
        [_co_datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
        _co_datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _co_datePicker;
}

- (DKClientRequest *)clientRequest
{
    if (_clientRequest == nil) {
        _clientRequest = [DKClientRequest new];
        _clientRequest.delegate = self;
    }
    return _clientRequest;
}

@end
