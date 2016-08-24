//
//  DKOutLinkViewController.m
//  DataKit
//
//  Created by wangyangyang on 15/12/18.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKOutLinkViewController.h"

@interface DKOutLinkViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *co_webView;
@property (nonatomic, strong) UIActivityIndicatorView *co_indicatorView;

@end

@implementation DKOutLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.co_webView];
    
    [self.view addSubview:self.co_indicatorView];
    [self.co_indicatorView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.co_indicatorView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [self performSelector:@selector(beginLoaded) withObject:nil afterDelay:0.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navLeftBtnTapped
{
    if ([self.co_webView canGoBack]) {
        [self.co_webView goBack];
    }
    else {
        [super navLeftBtnTapped];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.customeNavBarView.m_navTitleLabel.text = self.titleString?self.titleString:@"链接";
}

#pragma mark - private method

- (void)beginLoaded
{
    NSString *outLinkPathString = nil;
    if (self.outLinkPath && [self.outLinkPath hasPrefix:@"http://"]) {
        outLinkPathString = self.outLinkPath;
    }
    else {
        outLinkPathString = [NSString stringWithFormat:@"http://%@",self.outLinkPath];
    }
    [self.co_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:outLinkPathString]]];
}

/**
 *  重新加载
 */
- (void)webViewReload
{
    [self.co_webView reload];
}

#pragma mark - webView delegate

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.co_indicatorView startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self.co_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showNetworkErrorWithCallBack:@selector(webViewReload)];
}

#pragma mark - getters and setters

- (UIWebView *)co_webView
{
    if (_co_webView == nil) {
        _co_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, MMNavigationBarHeight, ScreenWidth, ScreenHeight - MMNavigationBarHeight)];
        _co_webView.delegate = self;
        _co_webView.scalesPageToFit = YES;
    }
    return _co_webView;
}

- (UIActivityIndicatorView *)co_indicatorView
{
    if (_co_indicatorView == nil) {
        _co_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _co_indicatorView;
}

@end
