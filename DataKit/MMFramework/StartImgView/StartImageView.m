//
//  StartImageView.m
//  ChengGuan
//
//  Created by Tiank on 14-4-3.
//  Copyright (c) 2013年 xinhuamm. All rights reserved.
//

#import "StartImageView.h"
#import "UIImageView+MMSDWebImageView.h"
#import "SDWebImageManager.h"
#import "StartImgObjec.h"
#import "UIView+WebCacheOperation.h"

UIKIT_EXTERN void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo);

#define IMGTAG 10
#define BTNTAG 11
#define TIPTAG 12

@interface StartImageView()
{
    /**
     *  旧的图片地址
     */
    NSString *oldImageString;
    
    /**
     *  旧的图片下载完
     */
    BOOL oldDownloadDone;
    
}

/**
 *  新图片下载完
 */
@property (nonatomic) BOOL newDownloadDone;

@end

@implementation StartImageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self beginRequest];
        
        //获取状态栏设置透明
        UIView *tmpView = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBar"];
        tmpView.alpha = 0.0f;
        //end
        
        //添加提示语
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(320, 160, 120, 70)];
        tipView.backgroundColor = [UIColor blackColor];
        tipView.alpha = 0.8f;
        tipView.tag = TIPTAG;
        [self addSubview:tipView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 120, 29)];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        [tipLabel setFont:[UIFont systemFontOfSize:15.0f]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"保存成功";
        [tipView addSubview:tipLabel];
        
        UIImageView *tipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(47, 10, 27, 27)];
        tipImgView.image = [UIImage imageNamed:@"face_done"];
        [tipView addSubview:tipImgView];
        //end
        
        //取出本地的启动图片 判断图片是否已经被下载
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *imgString = [userDefault objectForKey:@"IMGURL"];
        oldImageString = [imgString copy];

        UIImage *tmpImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imgString]]];
        
        if (tmpImage == nil)
        {
            [self setDispearNoImage];
            return self;
        }
        else
        {
            oldDownloadDone = YES;
            [self performSelector:@selector(setDispear) withObject:nil afterDelay:3.5];
        }
        //end
        
        //显示启动图片和下载按钮
        UIImageView *startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, frame.size.height)];
        startImageView.image = tmpImage;
        [startImageView setBackgroundColor:[UIColor clearColor]];
        startImageView.tag = IMGTAG;
        [self addSubview:startImageView];
        
//        //下载按钮
//        UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        downloadBtn.frame = CGRectMake(20, ScreenHeight - 64, 44, 44);
//        downloadBtn.tag = BTNTAG;
//        [downloadBtn setImage:[UIImage imageNamed:@"start_download"] forState:UIControlStateNormal];
//        [downloadBtn addTarget:self action:@selector(downImgTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:downloadBtn];
//        //end
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSendMsg)];
        [startImageView addGestureRecognizer:tap];
        startImageView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

#pragma mark -
#pragma mark - custom method
//图片显示3.5秒后消失
- (void) setDispear
{
    UIView *tmpView = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBar"];
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0;
        tmpView.alpha = 1.0f;
    } completion:^(BOOL finish){
        if (finish) {
            [self.superview sendSubviewToBack:self];
            //说明需要下载的新图片已经下载完了
            if (self.newDownloadDone) {
                [self removeFromSuperview];
            }
        }
    }];
}

//如果图片没有下载，不显示
- (void) setDispearNoImage
{
    self.alpha = 0;
    self.hidden = YES;
    UIView *tmpView = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBar"];
    tmpView.alpha = 1.0f;
}

- (void) beginRequest
{

    
    //[self.myRequest startImg];
    
}

- (void) tipDispear
{
    UIView *tipView = [self viewWithTag:TIPTAG];
    [UIView animateWithDuration:0.3
                     animations:^{
                         tipView.frame = (CGRect){320,160,tipView.frame.size};
                     }];
}

#pragma mark -
#pragma mark - 控件事件
- (void) downImgTapped:(UIButton *)sender
{
    UIImageView *tmpImgView = (UIImageView *)[self viewWithTag:IMGTAG];
    UIImageWriteToSavedPhotosAlbum(tmpImgView.image,nil, nil, nil);
    
    UIView *tipView = [self viewWithTag:TIPTAG];
    [self bringSubviewToFront:tipView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         tipView.frame = (CGRect){200,160,tipView.frame.size};
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(tipDispear) withObject:nil afterDelay:1.0f];
                     }];
}

#pragma mark -
#pragma mark - 消息处理函数
//启动图接口返回
- (void) startadCallBack:(id) objectData
{
    NSMutableArray *tmpArr = objectData;
    if ([tmpArr count] > 0)
    {
        StartImgObjec *tmpObj = [tmpArr objectAtIndex:0];
        if (! [tmpObj isKindOfClass:[StartImgObjec class]])
        {
            return;
        }
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:tmpObj.s_imgUrl forKey:@"IMGURL"];
        [userDefault setValue:tmpObj.s_hrefurl forKey:@"HREFURL"];
        [userDefault setValue:tmpObj.s_title forKey:@"USERSTARTTITLE"];
        [userDefault setValue:tmpObj.s_openType forKey:@"USERSTARTTYPE"];
        
        //当旧的图片和新的图片不一样，或者是旧的图片没有下载完时，再下载新的图片
        if ([oldImageString isEqualToString:tmpObj.s_imgUrl] == NO || oldDownloadDone == NO) {
            __weak __typeof(self)wself = self;
            id <SDWebImageOperation> operation =[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:tmpObj.s_imgUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                [wself removeFromSuperview];
            }];
            [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
        }
        else {
            self.newDownloadDone = YES;
            //说明当前试图已经隐藏掉了，则释放当前view
            if ([self alpha] == 0) {
                [self removeFromSuperview];
            }
        }
    }
}

//请求失败
- (void) failLoadData:(id) reasonString
{
    
}

- (void) tapSendMsg
{
    [self performSelector:@selector(setDispear) withObject:nil afterDelay:.1];
    //[[NSNotificationCenter defaultCenter] postNotificationName:STARTIMGTAPNOTIFICATION object:nil];
}

@end
