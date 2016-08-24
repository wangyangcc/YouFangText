//
//  CamaraObject.m
//  SanMen
//
//  Created by lcc on 13-12-27.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import "CamaraObject.h"
#import <AVFoundation/AVFoundation.h>
#import "MMAlertManage.h"

@implementation CamaraObject

- (void) openPicOrVideoWithSign:(NSInteger) sign
{
    switch (sign)
    {
        case 0:
            //本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self.c_delegate;
            //imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: @"public.image", nil];
            [MMAppDelegate.nav presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
            //照相机
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                imagePicker.delegate = self.c_delegate;
                //imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: @"public.image", nil];
                [MMAppDelegate.nav presentViewController:imagePicker animated:YES completion:^{
                    //判断是不是用户禁止了照相功能
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:@"请在iPhone的\"设置-隐私-相机\"选项中，允许有问访问你的相机。" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                        [alertManage show];
                        return;
                    }
                    //end
                }];
            }
        }
            break;
        default:
            break;
    }
}

//允许编辑
- (void) openPicOrVideoWithEditPhotoSign:(NSInteger) sign
{
    switch (sign)
    {
        case 0:
            //本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self.c_delegate;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: @"public.image", nil];
            [MMAppDelegate.nav presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
            //照相机
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){

                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                imagePicker.delegate = self.c_delegate;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: @"public.image", nil];
                [MMAppDelegate.nav presentViewController:imagePicker animated:YES completion:^{
                    //判断是不是用户禁止了照相功能
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        MMAlertManage *alertManage = [[MMAlertManage alloc] initWithTitle:@"请在iPhone的\"设置-隐私-相机\"选项中，允许有问访问你的相机。" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                        [alertManage show];
                        return;
                    }
                    //end
                }];
            }
        }
            break;
        default:
            break;
    }
}

@end
