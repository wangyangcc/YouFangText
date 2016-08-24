//
//  MMSocialIconActionSheet.m
//  XinHuaInternation
//
//  Created by wangyangyang on 15/1/25.
//  Copyright (c) 2015年 Xin Hua. All rights reserved.
//

#import "MMSocialIconActionSheet.h"
#import "NSObject+LogDealloc.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "UIImage+Ext.h"

#define kTagPageController 1000

@interface MMSocialIconActionSheet () <TencentSessionDelegate>
{
    UIButton *backgroundViewButton;
    NSDictionary *snsPlatformIcon;
    NSDictionary *snsPlatformText;
    
    NSInteger snsSelectType;
    
    TencentOAuth *tencentOauth;
}

@property (nonatomic, retain) NSArray *snsNames;

@property (nonatomic, weak) id socialUIDelegate;

@end


@implementation MMSocialIconActionSheet

-(void)dealloc
{
}

- (id)initWithItems:(NSArray *)items
          delegate:(id)delegate
         shareText:(NSString *)shareText
        shareImage:(id)shareImage
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.snsNames = items;
        _actionSheetBackground = nil;
        _cancelButton = nil;
        self.socialUIDelegate = delegate;
        
        m_shareImage = shareImage;
        m_shareText = shareText;
        
        NSMutableDictionary *Icon = [NSMutableDictionary dictionary];
        NSMutableDictionary *Text = [NSMutableDictionary dictionary];
        if ([WXApi isWXAppInstalled]) {
            [Icon addEntriesFromDictionary:@{
                                             UMShareToWechatSession : @"UMS_wechat_session_icon",
                                             UMShareToWechatTimeline : @"UMS_wechat_timeline_icon",
                                             }];
            [Text addEntriesFromDictionary:@{UMShareToWechatSession : @"微信好友",
                                             UMShareToWechatTimeline : @"朋友圈",}];
        }
        if ([QQApiInterface isQQInstalled]) {
            [Icon addEntriesFromDictionary:@{UMShareToQQ : @"UMS_qq_icon"}];
            [Text addEntriesFromDictionary:@{UMShareToQQ : @"QQ"}];
        }
        snsPlatformIcon = Icon;
        snsPlatformText = Text;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{

    float deltaY = 85.0;
    CGPoint startPoint = CGPointMake(20, 25);
    CGSize buttonSize = CGSizeMake(56, 56);
    CGSize labelSize = CGSizeMake(55, 20);
    float actionSheetHeight = 400;
    float buttomHeight = 20 + [UIApplication sharedApplication].statusBarFrame.size.height;
    int numPerRow = 3;
    CGRect fullFrame = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        fullFrame.size = CGSizeMake(fullFrame.size.height, fullFrame.size.width);
        buttomHeight = 20 + [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    float deltaX = (fullFrame.size.width - 2*startPoint.x)/numPerRow;
    float height = buttomHeight + ceil((float)self.snsNames.count/numPerRow) * deltaY;
    float width  = fullFrame.size.width;
    //处理iPhone5横屏的时候，自己的高度有可能超出屏幕高度
    NSInteger numPerPage = self.snsNames.count;
    int maxRowNum = UIInterfaceOrientationIsPortrait(orientation) ? 3 : 2;
    while (height > fullFrame.size.height || height > actionSheetHeight) {
        numPerRow ++;
        deltaX = (fullFrame.size.width - 2*startPoint.x)/numPerRow;
        height = buttomHeight  + ceil((float)self.snsNames.count/numPerRow) * deltaY;
        if (deltaX <  70) {
            width =  2 * width;
            height = (actionSheetHeight < fullFrame.size.height ) ? actionSheetHeight : (fullFrame.size.height );
            numPerRow --;
            deltaX = 70;
            numPerPage = numPerRow * maxRowNum;
            break;
        }
    }
    CGRect frame = CGRectMake(0, fullFrame.size.height - height,fullFrame.size.width,height);
    self.frame = frame;
    if (self.superview != nil) {
        UIView *backGroundView = self.superview;
        backGroundView.frame = fullFrame;
    }
    if (_actionSheetBackground == nil) {
        UIImage * backgroundImage = [UIImage imageNamed:@"UMSocialSDKResources.bundle/UMS_actionsheet_panel"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:30];
        _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundImageView.frame = CGRectMake(0, 0, width, height);
        _actionSheetBackground = [[UIScrollView alloc] initWithFrame:frame];
        _actionSheetBackground.showsHorizontalScrollIndicator = YES;
        _actionSheetBackground.contentSize = CGSizeMake(width, height);
        _actionSheetBackground.pagingEnabled = YES;
        _actionSheetBackground.scrollEnabled = YES;
        _actionSheetBackground.delegate = self;
        _actionSheetBackground.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [_actionSheetBackground addSubview:_backgroundImageView];
        _actionSheetBackground.frame = CGRectMake(0, 0, fullFrame.size.width, fullFrame.size.height);
        [self addSubview:_actionSheetBackground];
    }
    else{
        _actionSheetBackground.frame = CGRectMake(0, 0, fullFrame.size.width, fullFrame.size.height);
        _actionSheetBackground.contentSize = CGSizeMake(width, height);
        _backgroundImageView.frame = CGRectMake(0, 0, width, height);
    }
    if (_cancelButton == nil) {
        UIImage *image = [UIImage imageNamed:@"UMSocialSDKResources.bundle/UMS_actionsheet_button"];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
        UIImage *selectImage = [UIImage imageNamed:@"UMSocialSDKResources.bundle/UMS_actionsheet_button_selected"];
        selectImage = [selectImage stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, 200, 0);
        _cancelButton.center = CGPointMake(self.frame.size.width/2,self.frame.size.height - buttomHeight + _cancelButton.frame.size.height);
        [_cancelButton setBackgroundImage:image forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:selectImage forState:UIControlStateSelected];
        [_cancelButton addTarget:self action:@selector(dismiss)  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        if (width == 2 * fullFrame.size.width) {
            UIPageControl *pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(fullFrame.size.width/2 - 50, height - 140, 100, 30)];
            _cancelButton.center = CGPointMake(self.frame.size.width/2,self.frame.size.height - buttomHeight + _cancelButton.frame.size.height + 10);
            pageController.numberOfPages = 2;
            pageController.currentPage = 0;
            pageController.tag = kTagPageController;
            [_actionSheetBackground.superview addSubview:pageController];
        }
    }
    else{
        _cancelButton.center = CGPointMake(self.frame.size.width/2,self.frame.size.height - buttomHeight + _cancelButton.frame.size.height + 5);
        if (width == 2 * fullFrame.size.width) {
            UIPageControl *pageController = (UIPageControl *)[_actionSheetBackground.superview viewWithTag:1000];
            pageController.center = CGPointMake(_cancelButton.center.x, _cancelButton.center.y - 30);
        }
    }
    for (int i = 0 ; i < self.snsNames.count ; i++) {
        NSString *snsName = [self.snsNames objectAtIndex:i];

        NSString *snsDisplayName = [snsPlatformText objectForKey:snsName];;
        UILabel *snsNamelabel = (UILabel *)[self viewWithTag:300 + i];
        CGRect labelRect = CGRectMake(startPoint.x + deltaX * (i%numPerRow) + (deltaX-buttonSize.width)/2 + (i/numPerPage) * self.frame.size.width, buttonSize.height + startPoint.y + ((i%numPerPage)/numPerRow)*deltaY, labelSize.width, labelSize.height);
        if (snsNamelabel == nil) {
            UILabel *snsNamelabel = [[UILabel alloc] initWithFrame:labelRect];
            snsNamelabel.textAlignment = NSTextAlignmentCenter;
            [snsNamelabel setBackgroundColor:[UIColor clearColor]];
            [snsNamelabel setTextColor:[UIColor grayColor]];
            [snsNamelabel setFont:[UIFont systemFontOfSize:12]];
            [snsNamelabel setText:snsDisplayName];
            [_actionSheetBackground addSubview:snsNamelabel];
        }
        else{
            snsNamelabel.frame = labelRect;
        }
        UIButton *snsButton = (UIButton *)[self viewWithTag:i + 101];
        CGRect buttonRect = CGRectMake(startPoint.x + deltaX * (i%numPerRow) + (deltaX-buttonSize.width)/2 + (i/numPerPage) * self.frame.size.width, startPoint.y + ((i%numPerPage)/numPerRow)*deltaY , buttonSize.width, buttonSize.height);
        if (snsButton == nil) {
            UIButton *snsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *snsImage = [UIImage imageNamed:[snsPlatformIcon objectForKey:snsName]];
            [snsButton setBackgroundImage:snsImage forState:UIControlStateNormal];
            snsButton.frame = buttonRect;
            snsButton.tag = i + 101;
            [snsButton addTarget:self action:@selector(actionToSnsButton:) forControlEvents:UIControlEventTouchUpInside];
            [_actionSheetBackground addSubview:snsButton];
        }
        else{
            snsButton.frame = buttonRect;
        }
    }
    [super drawRect:self.frame];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (page == 1) {
        UIPageControl * pageControler = (UIPageControl *)[_actionSheetBackground.superview viewWithTag:kTagPageController];
        pageControler.currentPage = 1;
    }
    else if (page == 0)
    {
        UIPageControl * pageControler = (UIPageControl *)[_actionSheetBackground.superview viewWithTag:kTagPageController];
        pageControler.currentPage = 0;
    }
}


-(void)actionToSnsButton:(UIButton *)snsButton
{
    snsSelectType = (int)(snsButton.tag - 100);
    
    [self dismiss];
    
}

- (void)beginShare
{
    if (snsSelectType <= 2) {
        [self shareToWeixin];
    }
    else {
        [self shareToQQ];
    }
}

-(void)show
{
    UIView *showView = [[UIApplication sharedApplication] keyWindow];
    CGRect fullFrame = [[UIScreen mainScreen] bounds];

    if ([self superview] == nil) {
        
        self.center = CGPointMake(fullFrame.size.width/2, fullFrame.size.height + fullFrame.size.height/2 );
        UIButton *backgroundView = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundView.frame = showView.bounds;
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0.0;
        [backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [showView addSubview:backgroundView];

        backgroundViewButton = backgroundView;
        self.tag = 11111111;
        [showView addSubview:self];
        
    }

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         backgroundViewButton.alpha = 0.7f;
                         self.center = CGPointMake(fullFrame.size.width/2, fullFrame.size.height - fullFrame.size.height/2 );
                     } completion:^(BOOL finished) {
                     }];
}

-(void)dismiss
{
    CGRect fullFrame = [[UIScreen mainScreen] bounds];

    [self logOnDealloc];
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        backgroundViewButton.alpha = 0.0f;
        self.center = CGPointMake(fullFrame.size.width/2, fullFrame.size.height + self.frame.size.height/2);
    } completion:^(BOOL finished){
        [backgroundViewButton removeFromSuperview];
        [self removeFromSuperview];
        if (snsSelectType > 0) {
            [self beginShare];
        }
    }];
}

#pragma mark - share 

- (void)shareToQQ
{
    //判断用户是否安装了qq
    if ([QQApiInterface isQQInstalled] == NO) {
        [SVProgressHUD showInfoWithStatus:@"您没有安装QQ，请先下载安装"];
        return;
    }
    //登录授权
    tencentOauth = [[TencentOAuth alloc]initWithAppId:Tencent_AppId andDelegate:self];

    NSData* data = UIImagePNGRepresentation(m_shareImage);
    
    QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:data title:@"" description:@""];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)shareToWeixin
{
    //判断用户是否安装了微信
    if ([WXApi isWXAppInstalled] == NO) {
        [SVProgressHUD showInfoWithStatus:@"您没有安装微信，请先下载安装"];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"";
    message.description = @"";

    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(m_shareImage);
    message.mediaObject = imageObject;
    message.thumbData = UIImagePNGRepresentation([UIImage imageWithImage:m_shareImage scaledToSize:CGSizeMake(160, 160 * ScreenHeight/ScreenWidth)]);
    //message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";

    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (snsSelectType == 1 ? WXSceneSession:WXSceneTimeline);
    [WXApi sendReq:req];
}

@end
