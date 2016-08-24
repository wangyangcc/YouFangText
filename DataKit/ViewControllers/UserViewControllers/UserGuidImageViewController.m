//
//  UserGuidImageViewController.m
//  SanMen
//
//  Created by lcc on 13-12-29.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import "UserGuidImageViewController.h"
#import "MetaData.h"
#import "FMDBManage.h"

#define IMAGESCOUNT 3

@interface UserGuidImageViewController () <UIScrollViewDelegate>
{
    NSInteger currentIndex;
}

@property (strong, nonatomic) UIScrollView *ui_scrollView;

@end

@implementation UserGuidImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _ui_scrollView = nil;
}

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];
    self.ui_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.ui_scrollView.pagingEnabled = YES;
    self.ui_scrollView.showsHorizontalScrollIndicator = NO;
    self.ui_scrollView.bounces = NO;
    [self.view addSubview:self.ui_scrollView];
    [self.ui_scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *tmpView = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBar"];
    tmpView.alpha = 0;
    
    for (int i = 0; i < IMAGESCOUNT; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * ScreenWidth, 0, ScreenWidth, ScreenHeight)];
        [self.ui_scrollView addSubview:imageView];
        
        
        if ([MetaData isIphone6plus])
        {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d-6p",i + 1]];
        }
         else if ([MetaData isIphone6])
        {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d-6",i + 1]];
        }
        else if ([MetaData isIphone5_5s])
        {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d-568",i + 1]];
        }
        else
        {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%d",i + 1]];
        }
        
        if (i == IMAGESCOUNT - 1) {
            imageView.userInteractionEnabled = YES;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [btn addTarget:self action:@selector(startTapped:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(0, ScreenHeight/2, ScreenWidth, ScreenHeight/2);
            [imageView addSubview:btn];
        }
    }
    self.ui_scrollView.contentSize = CGSizeMake(ScreenWidth*IMAGESCOUNT, 0);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 控件事件

- (void)startTapped:(id)sender
{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {

        [MMAppDelegate.appModel updateNotDisplayFirstUserGuide];
        [self.view removeFromSuperview];
        MMAppDelegate.userGuid = nil;

        UIView *tmpView = (UIView *)[[UIApplication sharedApplication] valueForKey:@"statusBar"];
        tmpView.alpha = 1;
    }];
}

@end
