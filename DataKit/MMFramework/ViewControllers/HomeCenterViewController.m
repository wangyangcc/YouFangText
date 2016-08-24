//
//  HomeCenterViewController.m
//  TestNav
//
//  Created by lcc on 13-11-29.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import "HomeCenterViewController.h"

#define LeftWidth 60
#define RightWidth 60

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define AnimationDuration 0.3

#define LeftBtnTag 10
#define RightBtnTag 11
#define CenterTitleTag 120
#define DownTitleLabelTag 130

#define TitleString @"首页"

@interface HomeCenterViewController ()
{
    CGPoint startTouch;
    CGFloat tmpX;
    UIImageView *tapView;
    CGFloat originY;
}

@property (strong, nonatomic) UIView *markView;
@property (nonatomic, strong) SuperViewController *centreVC;
@property (strong, nonatomic) NSMutableDictionary *centerViewControllers;

@end

@implementation HomeCenterViewController

- (void)dealloc
{
    self.markView = nil;
    self.centreVC = nil;
    self.centerViewControllers = nil;
    tapView = nil;
}

#pragma mark -
#pragma mark - 系统默认生成
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {   
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化中间页面的堆栈
    self.centerViewControllers = [[NSMutableDictionary alloc] init];
    
    //初始化左右界面
    [self initVC];
    
    //添加手势
    //[self addGesture];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 自定义方法 - 更换viewcontroller
- (void) initVC
{
    //左边view
    if (!self.leftVC)
    {
        self.leftVC = [[SuperViewController alloc] init];
    }
    CGRect tmpLeftRect = self.leftVC.view.frame;
    tmpLeftRect.origin.x = -160;
    tmpLeftRect.size.width = 319;
    tmpLeftRect.size.height = ScreenHeight;
    self.leftVC.view.frame = tmpLeftRect;
    [self.view addSubview:self.leftVC.view];
    self.leftVC.s_delegate = self;

    //右边view
    if (!self.rightVC)
    {
        self.rightVC = [[SuperViewController alloc] init];
    }
    CGRect tmpRightRect = self.rightVC.view.frame;
    tmpRightRect.origin.x = 160;
    tmpRightRect.size.width = 319;
    tmpRightRect.size.height = ScreenHeight;
    self.rightVC.view.frame = tmpRightRect;
    [self.view addSubview:self.rightVC.view];
    self.rightVC.s_delegate = self;
    
    //中间view
    if (!self.centreVC)
    {
        self.centreVC = [[SuperViewController alloc] init];
    }
    CGRect tmpCentreRect = self.centreVC.view.frame;
    tmpCentreRect.origin.x = 0;
    tmpCentreRect.origin.y = originY;
    self.centreVC.view.frame = tmpCentreRect;
    self.centreVC.view.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:137.0f/255.0f blue:217.0f/255.0f alpha:1.0];
    
    [self.view addSubview:self.centreVC.view];
    
    //添加左右按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = (CGRect){0,20,44,44};
    [leftBtn setImage:[UIImage imageNamed:@"home_left"] forState:UIControlStateNormal];
    [self.centreVC.view addSubview:leftBtn];
    
    [leftBtn addTarget:self action:@selector(leftMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = LeftBtnTag;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = (CGRect){276,20,44,44};
    [rightBtn setImage:[UIImage imageNamed:@"home_right"] forState:UIControlStateNormal];
    [self.centreVC.view addSubview:rightBtn];
    [rightBtn addTarget:self action:@selector(rightMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = RightBtnTag;
    
    //中间标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, ScreenWidth, 24)];
    [titleLabel setFont:[UIFont systemFontOfSize:20]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.centreVC.view addSubview:titleLabel];
    titleLabel.tag = CenterTitleTag;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = TitleString;
    
    UILabel *downTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, ScreenWidth, 24)];
    [downTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [downTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.centreVC.view addSubview:downTitleLabel];
    downTitleLabel.tag = DownTitleLabelTag;
    downTitleLabel.backgroundColor = [UIColor clearColor];
    downTitleLabel.textColor = [UIColor whiteColor];
    
    //设置首页
    if (self.centerVCString)
    {
        SuperViewController *tmpVC = [[NSClassFromString(self.centerVCString) alloc] init];
        [self.centerViewControllers setObject:tmpVC forKey:self.centerVCString];
        CGFloat topHeight = 64;
        if (self.centerIsTop)
        {
            topHeight = 0;
        }
        tmpVC.view.frame = (CGRect){0,topHeight,ScreenWidth,ScreenHeight - topHeight};
        [self.centreVC.view addSubview:tmpVC.view];
    }
    
    //单击view
    tapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, tmpCentreRect.size.height)];
    tapView.userInteractionEnabled = YES;
    tapView.backgroundColor = [UIColor clearColor];
    [self.centreVC.view addSubview:tapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapView.hidden = YES;
    [tapView addGestureRecognizer:tapGesture];
    
    //添加阴影
    self.markView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.markView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.markView];
    self.markView.alpha = 0;
    
    [self.view bringSubviewToFront:self.centreVC.view];
}

//添加手势滑动
- (void) addGesture
{
    if ([self.view.gestureRecognizers count] == 0)
    {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                    action:@selector(paningGestureReceive:)];
        recognizer.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:recognizer];
    }
}

//移除手势滑动
- (void) removeGesture
{
    if ([self.view.gestureRecognizers count] > 0)
    {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers objectAtIndex:0]];
    }
}

//设置界面
- (void) setCenterViewControllerWithString:(NSString *) VCString object:(id) object
{
    [self viewTapped:nil];
    
    UILabel *tmpLabel = (UILabel *)[self.centreVC.view viewWithTag:CenterTitleTag];
    tmpLabel.text = [NSString stringWithFormat:@"%@",object];
    
    
    if ([self.centerViewControllers.allKeys containsObject:self.centerVCString])
    {
        SuperViewController *tmpVC = [self.centerViewControllers objectForKey:self.centerVCString];
        tmpVC.s_delegate = nil;
        [tmpVC.view removeFromSuperview];
        [self.centerViewControllers removeObjectForKey:self.centerVCString];
        tmpVC = nil;
    }
    
    SuperViewController *tmpVC = [[NSClassFromString(VCString) alloc] init];
    tmpVC.s_delegate = self;
    [self.centerViewControllers setObject:tmpVC forKey:VCString];
    
    if (self.centerIsTop)
    {
        tmpVC.view.frame = (CGRect){0,0,ScreenWidth,ScreenHeight};
    }
    else
    {
        tmpVC.view.frame = (CGRect){0,64,ScreenWidth,ScreenHeight - 64};
    }
    
    [self.centreVC.view addSubview:tmpVC.view];
    
    if ([tmpVC respondsToSelector:@selector(loadWithObject:)])
    {
        [tmpVC performSelectorInBackground:@selector(loadWithObject:) withObject:object];
    }
    
    self.centerVCString = VCString;
    
    //标题切换
    [self msg_SCROLLDOWNNOTIFICATION:nil];
    
}

#pragma mark -
#pragma mark - 按钮事件
- (void) viewTapped:(id) sender
{
    __block CGRect centerRect = [self.centreVC.view frame];
    __block CGRect leftRect = [self.leftVC.view frame];
    __block CGRect rightRect = [self.rightVC.view frame];
    
    [UIView animateWithDuration:AnimationDuration
                     animations:^{
                         rightRect.origin.x = 160;
                         leftRect.origin.x = -160;
                         centerRect.origin.x = 0;
                         
                         self.markView.alpha = 0.9;
                         self.centreVC.view.frame = centerRect;
                         self.leftVC.view.frame = leftRect;
                         self.rightVC.view.frame = rightRect;
                     }];
    tmpX = 0;
    tapView.hidden = YES;
    
    [self addGesture];
    
}

//左边菜单按钮单击
- (void) leftMenuTapped:(UIButton *) sender
{
    __block CGRect centerRect = [self.centreVC.view frame];
    __block CGRect leftRect = [self.leftVC.view frame];
    
    [self.view sendSubviewToBack:self.rightVC.view];
    self.leftVC.view.hidden = NO;
    tmpX = 260;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         
                         centerRect.origin.x = ScreenWidth - LeftWidth;
                         leftRect.origin.x = 0;
                         self.markView.alpha = 0.0;
                         
                         self.centreVC.view.frame = centerRect;
                         self.leftVC.view.frame = leftRect;
                         
                     } completion:^(BOOL finish){
                         tapView.hidden = NO;
                         [self.centreVC.view bringSubviewToFront:tapView];
                     }];
}

//右边菜单按钮单击
- (void) rightMenuTapped:(UIButton *) sender
{
    __block CGRect centerRect = [self.centreVC.view frame];
    __block CGRect rightRect = [self.rightVC.view frame];
    
    [self.view sendSubviewToBack:self.leftVC.view];
    self.rightVC.view.hidden = NO;
    tmpX = - 260;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         centerRect.origin.x = RightWidth - ScreenWidth;
                         rightRect.origin.x = 0;
                         self.markView.alpha = 0.0;
                         
                         self.centreVC.view.frame = centerRect;
                         self.rightVC.view.frame = rightRect;
                         
                     } completion:^(BOOL finish){
                         tapView.hidden = NO;
                         [self.centreVC.view bringSubviewToFront:tapView];
                     }];
}

#pragma mark -
#pragma mark - 代理方法 -

#pragma mark -
#pragma mark - 消息处理 - 标题上下切换
- (void) msg_SCROLLUPNOTIFICATION:(NSNotification *) notication
{
    UILabel *titleLabel = (UILabel *)[self.centreVC.view viewWithTag:CenterTitleTag];
    CGRect titleRect = titleLabel.frame;
    titleRect.origin.y = -30;
    
    UILabel *downTitleLabel = (UILabel *)[self.centreVC.view viewWithTag:DownTitleLabelTag];
    CGRect downTitleRect = downTitleLabel.frame;
    downTitleRect.origin.y = 30;
    downTitleLabel.text = notication.object;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         titleLabel.frame = titleRect;
                         downTitleLabel.frame = downTitleRect;
                     }];
}

- (void) msg_SCROLLDOWNNOTIFICATION:(NSNotification *) notication
{
    UILabel *titleLabel = (UILabel *)[self.centreVC.view viewWithTag:CenterTitleTag];
    CGRect titleRect = titleLabel.frame;
    titleRect.origin.y = 30;
    
    UILabel *downTitleLabel = (UILabel *)[self.centreVC.view viewWithTag:DownTitleLabelTag];
    CGRect downTitleRect = downTitleLabel.frame;
    downTitleRect.origin.y = 65;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         titleLabel.frame = titleRect;
                         downTitleLabel.frame = downTitleRect;
                     }];
}

- (void) msg_CHANGETITLENOTIFICATION:(NSNotification *) notication
{
    UILabel *downTitleLabel = (UILabel *)[self.centreVC.view viewWithTag:DownTitleLabelTag];
    downTitleLabel.text = notication.object;
}

#pragma mark -
#pragma mark - 其他 - 手势 -
- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    __block CGRect centerRect = [self.centreVC.view frame];
    __block CGRect leftRect = [self.leftVC.view frame];
    __block CGRect rightRect = [self.rightVC.view frame];
    
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan)
    {
        startTouch = touchPoint;
    }
    else if (recoginzer.state == UIGestureRecognizerStateEnded)
    {
        
        [UIView animateWithDuration:0.4
                         animations:^{
                             if (centerRect.origin.x >= -120 && centerRect.origin.x <= 120)
                             {
                                 centerRect.origin.x = 0;
                                 leftRect.origin.x = -160;
                                 rightRect.origin.x = 160;
                                 self.markView.alpha = 0.9;
                             }
                             else if(centerRect.origin.x > 120)
                             {
                                 centerRect.origin.x = ScreenWidth - LeftWidth;
                                 leftRect.origin.x = 0;
                                 self.markView.alpha = 0.0;
                             }
                             else if(centerRect.origin.x < -120)
                             {
                                 centerRect.origin.x = RightWidth - ScreenWidth;
                                 rightRect.origin.x = 0;
                                 self.markView.alpha = 0.0;
                             }
                             self.centreVC.view.frame = centerRect;
                             self.leftVC.view.frame = leftRect;
                             self.rightVC.view.frame = rightRect;
                             
                         } completion:^(BOOL finish){
                             switch ((int)centerRect.origin.x)
                             {
                                 case 0:
                                     tapView.hidden = YES;
                                     break;
                                     
                                 default:
                                     tapView.hidden = NO;
                                     [self.centreVC.view bringSubviewToFront:tapView];
                                     break;
                             }
                         }];
        tmpX = centerRect.origin.x;
        
    }
    else if(recoginzer.state == UIGestureRecognizerStateChanged)
    {
        if ((ScreenWidth - LeftWidth == centerRect.origin.x && (0 <= touchPoint.x && touchPoint.x < ScreenWidth - LeftWidth))||(RightWidth - ScreenWidth == centerRect.origin.x && (RightWidth < touchPoint.x && touchPoint.x <= ScreenWidth)))
        {
            return;
        }
        
        if ((startTouch.x < ScreenWidth - LeftWidth && startTouch.x >= 0) && (ScreenWidth - LeftWidth == centerRect.origin.x))
        {
            return;
        }
        
        if ((startTouch.x < ScreenWidth && startTouch.x >= RightWidth) && RightWidth - ScreenWidth == centerRect.origin.x)
        {
            return;
        }
        
        //根据手指移动中间窗体
        centerRect.origin.x = touchPoint.x - startTouch.x + tmpX;

        //禁止左边页面
        if (self.leftVcHidden == YES)
        {
            if (centerRect.origin.x > 0)
            {
                centerRect.origin.x = 0;
                self.centreVC.view.frame = centerRect;
                return;
            }
        }
        
        //禁止右边边页面
        if (self.rightVcHidden == YES)
        {
            if (centerRect.origin.x < 0)
            {
                centerRect.origin.x = 0;
                self.centreVC.view.frame = centerRect;
                return;
            }
        }
    
        //来回显示左边和右边
        if (centerRect.origin.x < 0)
        {
            self.rightVC.view.hidden = NO;
            self.leftVC.view.hidden = YES;
            
            if (centerRect.origin.x < RightWidth - ScreenWidth)
            {
                rightRect.origin.x = 0;
                self.markView.alpha = 0;
                self.rightVC.view.frame = rightRect;
                return;
            }
            else
            {
                rightRect.origin.x = centerRect.origin.x*8.0f/13.0f + 160.0f;
                self.markView.alpha = 0.9 + 0.9f*centerRect.origin.x/(ScreenWidth - RightWidth);
            }
            
            self.rightVC.view.frame = rightRect;
        }
        else
        {
            self.rightVC.view.hidden = YES;
            self.leftVC.view.hidden = NO;
            
            if (centerRect.origin.x > (ScreenWidth - LeftWidth))
            {
                leftRect.origin.x = 0;
                self.leftVC.view.frame = leftRect;
                self.markView.alpha = 0;
                
                return;
            }
            else
            {
                leftRect.origin.x = centerRect.origin.x*8.0f/13.0f - 160.0f;
                self.markView.alpha = 0.9 - 0.9f*centerRect.origin.x/(ScreenWidth - LeftWidth);
            }
            self.leftVC.view.frame = leftRect;
        }
        
        
        self.centreVC.view.frame = centerRect;
    }
}

@end
