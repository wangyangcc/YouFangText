//
//  DKUserViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/11/24.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKUserViewController.h"
#import "A3ParallaxScrollView.h"
#import "DKOutLinkViewController.h"
#import "MMAppDelegateHelper.h"
#import "NSString+URLEncoding.h"

@interface DKUserViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIImageView *userImageView;
    UILabel *userNameLabel;
    
    __weak id<NSObject> notificationOne;
}

@property (nonatomic, strong) UIImageView *co_picImageView;

@end

@implementation DKUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateViewStyle];
    
    //用户选择设备改变通知，更新用户头像
    notificationOne = [[NSNotificationCenter defaultCenter] addObserverForName:kUserSelectedDeviceChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self updateDeviceData];
    }];
    //end
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom method

- (void)updateViewStyle
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航条的背景
    UIView *satatView = [UIView new];
    satatView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    satatView.frame = CGRectMake(0, 0, ScreenWidth, 20);
    [self.view addSubview:satatView];
    //end
    
    //设置导航条
    self.customeNavBarView.m_navTitleLabel.text = @"账户";
    self.customeNavBarView.m_navLeftBtn.hidden = YES;
    self.customeNavBarView.backgroundColor = [UIColor clearColor];
    self.customeNavBarView.m_navBackgroundImage.image = nil;
    self.customeNavBarView.m_navBackgroundImage.backgroundColor = [UIColor clearColor];
    //end

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 49)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - 40);
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    
    //顶部背景
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 240*ScreenWidth/375)];
    imageV.image = [UIImage imageNamed:@"login_bl"];
    self.co_picImageView = imageV;
    [scrollView addSubview:imageV];
    //end
    
    //用户头像
    UIImageView *userImage = [[UIImageView alloc] init];
    userImage.frame = CGRectMake((ScreenWidth - 68)/2, (240*ScreenWidth/375 - 88) - 68 + [MetaData valueForDeviceCun3_5:30 cun4:25 cun4_7:0 cun5_5:0], 68, 68);
    userImage.backgroundColor = [UIColor whiteColor];
    userImage.layer.masksToBounds = YES;
    userImage.layer.cornerRadius = 35; //圆角
    [scrollView addSubview:userImage];
    userImageView = userImage;
    //end
    
    //标题
    UILabel *titleLable = [UILabel new];
    titleLable.text = AppName;
    titleLable.font = [UIFont systemFontOfSize:20];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.frame = CGRectMake(50, (240*ScreenWidth/375 - 46) - 20 + [MetaData valueForDeviceCun3_5:25 cun4:20 cun4_7:0 cun5_5:0], ScreenWidth - 100, 25);
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:titleLable];
    userNameLabel = titleLable;
    //end
    
    //切换按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"userChange"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(userChange) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(ScreenWidth - 60 - 25, 240*ScreenWidth/375 - 30, 60, 60);
    [scrollView addSubview:button];
    //end
    
    //表格
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 240*ScreenWidth/375 + 17, ScreenWidth, ScreenHeight - 49 - 240*ScreenWidth/375 - 17) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    [scrollView addSubview:tableView];
    //end
    
    [self.view addSubview:scrollView];
    
    [self updateDeviceData];
}

- (void)updateDeviceData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        DKUser *user = [[MMAppDelegateHelper shareHelper] currentUser];
        if (user) {
            DKDeviceInfo *deviceInfo = [user getSelectedDeviceInfo];
            [userImageView setImageWithURL:[NSURL URLWithString:deviceInfo.photoPath] placeholderImage:[UIImage imageNamed:deviceInfo.sex == 1 ? @"user_default_woman" : @"user_default_man"]];
            userNameLabel.text = deviceInfo.relation;
        }
        else {
            userImageView.image = [UIImage imageNamed:@"user_default"];
            userNameLabel.text = AppName;
        }
    });
}

#pragma mark - event

- (void)userChange
{
    [MMAppDelegate.nav pushViewController:[NSClassFromString(@"DKAccountSwitchViewController") new]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    cell.textLabel.text = indexPath.row == 0 ? @"帮助" : @"关于";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *urlPath = indexPath.row == 0 ? [MMAppDelegate.updateHelper getHelpUrlPath] : [MMAppDelegate.updateHelper getAboutUrlPath];
    if (urlPath == nil) {
        [SVProgressHUD showInfoWithStatus:@"网络连接失败"];
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    DKOutLinkViewController *viewController = [[DKOutLinkViewController alloc] init];
    viewController.titleString = cell.textLabel.text;
    viewController.outLinkPath = urlPath;
    [MMAppDelegate.nav pushViewController:viewController];
}

@end
