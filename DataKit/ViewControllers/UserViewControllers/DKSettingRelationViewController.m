//
//  DKSettingRelationViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKSettingRelationViewController.h"
#import "CamaraObject.h"
#import "UIViewController+tapCanceGesture.h"
#import "CustomIOSAlertView.h"
#import "DKAlertSexEditView.h"
#import "DKEditDataViewController.h"
#import "NSString+URLEncoding.h"
#import "MMAppDelegateHelper.h"

@interface DKSettingRelationViewController () <UITextFieldDelegate, MMAlertManageDelegate>
{
    CGFloat contentViewHeight; /**< scrollview内容view的高度 */
    
    NSInteger photoType;
    CamaraObject *camaraObject;
    
    BOOL sexSelectedAlertViewShowed;
    
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

@property (nonatomic, weak) IBOutlet UITextField *ui_textField;

@property (nonatomic, weak) IBOutlet UIImageView *ui_picImageView;

@property (nonatomic, weak) IBOutlet UIButton *ui_picButton;

@property (nonatomic, weak) IBOutlet UIView *ui_recommendNameView;

@property (nonatomic, strong) DKClientRequest *photoRequest;

@end

@implementation DKSettingRelationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateViewStyle];
    
    __weak typeof(self) weakSelf = self;
    [self addTapCanceGestureWithBlock:^{
        [weakSelf textFieldFrameChange:weakSelf.ui_textField isUp:NO];
        [weakSelf.view endEditing:YES];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (sexSelectedAlertViewShowed == NO) {
        [self choseSex];
    }
    
    if (!isUpdate) {
        isUpdate = YES;
        if (self.deviceInfo.photoPath && [self.deviceInfo.photoPath length] > 0) {
            [self.ui_picImageView setImageWithURL:[NSURL URLWithString:self.deviceInfo.photoPath] placeholderImage:nil];
            [self.ui_picButton setImage:nil forState:UIControlStateNormal];
            self.ui_picImageView.contentMode = UIViewContentModeScaleToFill;
        }
        if (self.deviceInfo.relation) {
            self.ui_textField.text = self.deviceInfo.relation;
        }
    }
}

- (void)navLeftBtnTapped
{
    if (self.isEditModel) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    else {
        [super navLeftBtnTapped];
    }
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

#pragma mark - custom method

- (void)updateViewStyle
{
    //设置导航条
    self.customeNavBarView.backgroundColor = [UIColor clearColor];
    self.customeNavBarView.m_navBackgroundImage.image = nil;
    self.customeNavBarView.m_navBackgroundImage.backgroundColor = [UIColor clearColor];
    self.customeNavBarView.m_navTitleLabel.text = @"设置";
    //end
    
    //设置输入框
    self.ui_textField.backgroundColor = MMRGBColor(240, 241, 242);
    self.ui_textField.layer.masksToBounds = YES;
    self.ui_textField.layer.cornerRadius = 7; //圆角
    //end
    
    //设置头像
    self.ui_picImageView.backgroundColor = [UIColor whiteColor];
    self.ui_picImageView.layer.masksToBounds = YES;
    self.ui_picImageView.layer.cornerRadius = 44; //圆角
    //end
    
    //设置滑动试图内容高度
    contentViewHeight = MAX(644, ScreenHeight + 5);
    //end
}

- (void)choseSex
{
    __block CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.alertViewCornerRadius = 12.0f;
    alertView.cancelBlurViewTaped = YES;
    
    DKAlertSexEditView *afterV = [[DKAlertSexEditView alloc] initWithFrame:CGRectMake(0, 0, [alertView width] - 46, 320)];
    afterV.backgroundColor = [UIColor whiteColor];
    afterV.defaultSelectIndex = self.deviceInfo.sex > 0 ? (self.deviceInfo.sex == 2 ? 0 : 1) : 0;
    __weak typeof(self) weakSelf = self;
    __weak typeof(CustomIOSAlertView) *weakAlertView = alertView;
    [afterV setOnButtonTouchUpInside:^(DKAlertSexEditView *sexEditView, NSInteger buttonIndex) {
        sexSelectedAlertViewShowed = YES;
        weakSelf.deviceInfo.sex = (buttonIndex == 0 ? 2 : 1);
        if (weakSelf.deviceInfo.sex == 1) {
            NSArray *sexNames = @[@"妈妈", @"奶奶", @"外婆", @"本人"];
            for (NSInteger index = 1; index < 5; index ++) {
                UIButton *button = [weakSelf.ui_recommendNameView viewWithTag:100 + index];
                [button setTitle:sexNames[index-1] forState:UIControlStateNormal];
            }
        }
        [weakAlertView close];
    }];
    [alertView setContainerView:afterV];
    alertView.blurView.underlyingView = MMAppDelegate.nav.visibleViewController.view;
    [alertView show];
}

- (void)textFieldFrameChange:(UITextField *)textField
                        isUp:(BOOL)isUp
{
    if ([MetaData isIphone4_4s]) {
        [self.ui_scrollView setContentOffset:CGPointMake(0, isUp?100:0) animated:YES];
    }
}

#pragma mark - event

- (IBAction)nextTaped:(id)sender
{
    if ([self.ui_textField.text length] <= 0) {
        [SVProgressHUD showInfoWithStatus:@"输入使用者和您的关系"];
        return;
    }
    self.deviceInfo.relation = self.ui_textField.text;
    
//    //说明是已经绑定过的手表
//    if (self.isBinded) {
//        DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
//        NSMutableArray *newTerminals = [NSMutableArray array];
//        if (user.terminals) {
//            [newTerminals addObjectsFromArray:user.terminals];
//        }
//        [newTerminals insertObject:self.deviceInfo atIndex:0];
//        user.terminals = newTerminals;
//        [[MMAppDelegateHelper shareHelper] updateWithUser:user];
//        [SVProgressHUD showSuccessWithStatus:@"此手表已被绑定过，已跳过设置个人信息"];
//        [MMAppDelegate.nav dismissViewControllerAnimated:YES completion:NULL];
//        return;
//    }
    
    DKEditDataViewController *viewController = [DKEditDataViewController new];
    viewController.deviceInfo = [self.deviceInfo copy];
    viewController.isEditModel = self.isEditModel;
    viewController.isBinded = self.isBinded;
    [MMAppDelegate.nav pushViewController:viewController];
}

- (IBAction)relationTaped:(UIButton *)sender
{
    NSString *selectTitle = [sender titleForState:UIControlStateNormal];
    self.ui_textField.text = selectTitle;
}

- (IBAction)picImageTaped:(id)sender
{
    if (camaraObject == nil) {
        camaraObject = [CamaraObject new];
        camaraObject.c_delegate = self;
    }
    if (_photoRequest) {
        [SVProgressHUD showInfoWithStatus:@"头像上传中，请稍后重试"];
        return;
    }
    //修改头像
    MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择",nil];
    [alertManage showInView:[MMAppDelegate.nav view]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self textFieldFrameChange:textField isUp:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self textFieldFrameChange:textField isUp:NO];
    return YES;
}

#pragma mark - MMAlertManageDelegate

- (void)actionSheet:(MMAlertManage *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //取消按钮
    if (buttonIndex == 2) {
        return;
    }
    if (buttonIndex == 1) {
        photoType = 0;
        [camaraObject openPicOrVideoWithEditPhotoSign:photoType];
    }
    else if (buttonIndex == 0) {
        photoType = 1;
        [camaraObject openPicOrVideoWithEditPhotoSign:photoType];
    }
}

#pragma mark - UIImagePickerControllerDelegate

//相机操作
-  (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        
        if (photoType == 1)
        {
            UIImageWriteToSavedPhotosAlbum(img,self, nil, nil);
        }
        
        @try {
            //将图片转换成base64流
            NSData *imageData = UIImageJPEGRepresentation(img, 0.2);
            NSString *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserHeadImagePath.png"];
            if ([imageData writeToFile:imagePath atomically:NO]) {
                [self.ui_picImageView setImage:img];
                [self.ui_picButton setImage:nil forState:UIControlStateNormal];
                self.ui_picImageView.contentMode = UIViewContentModeScaleToFill;
                [self.photoRequest imageUpavatarWithImageUrlPath:imagePath];
            }
            else {
                [SVProgressHUD showErrorWithStatus:NetFailTip];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
}

#pragma mark - DKClientRequestCallBackDelegate

- (void)requestDidSuccessCallBack:(DKClientRequest *)clientRequest
{
    self.photoRequest = nil;
    NSDictionary *resultDic = clientRequest.responseObject;
    //判断结果
    if ([resultDic[@"result"] isEqualToString:REQUEST_SUCCESS]) {
        self.deviceInfo.photoPath = resultDic[@"fileURL"];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"上传图片失败，请稍后重试"];
    }
}

- (void)requestDidFailCallBack:(DKClientRequest *)clientRequest
{
    self.photoRequest = nil;
    [SVProgressHUD showErrorWithStatus:@"上传图片失败，请稍后重试"];
}

#pragma mark - getters 

- (DKClientRequest *)photoRequest
{
    if (_photoRequest == nil) {
        _photoRequest = [DKClientRequest new];
        _photoRequest.delegate = self;
    }
    return _photoRequest;
}

@end
