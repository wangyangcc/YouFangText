//
//  MLNavigationController.m
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#import <objc/runtime.h>
#import "MMTabbarController.h"

#define shadowMin   0.2
#define shadowMax   0.7

#define PushPopTime  0.35

#define M_N_62 ((NSInteger)62*(SelfView_W/320.0f))

#define M_N_98 ((NSInteger)98*(SelfView_W/320.0f))

static CGFloat shadowViewMinAlpha = 0.2; //shadowView 最低的透明度

#define SelfView_H CGRectGetHeight(self.view.frame)

#define SelfView_W CGRectGetWidth(self.view.frame)

typedef NS_ENUM(NSUInteger, MMGestureRecognizerDirection)
{
    MMGestureRecognizerDirectionLeft = -1,
    MMGestureRecognizerDirectionNatural = 0,
    MMGestureRecognizerDirectionRight = 1,
};

@interface MLNavigationController ()
{
    
    UIView *shadowView;
    MMGestureRecognizerDirection recognizerDirection;
    
    UIViewController *nextViewController;
    
    //用于兼容iOS7下的手势滑动返回问题
    UIViewController * rightwardsOutViewController;
    
    UIViewController * rightwardsInViewController;
}

@property (nonatomic, strong) UIPanGestureRecognizer *m_interactivePopGestureRecognizer;

@end

@implementation MLNavigationController
@synthesize interactivePopGestureRecognizer = _interactivePopGestureRecognizer;

- (void)dealloc
{
    self.delegate = nil;
    shadowView = nil;
    self.m_interactivePopGestureRecognizer = nil;
    self.m_delegate = nil;
}

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
    
    self.isSlider = YES;
    
    // ios 7 下去掉 左滑返回功能
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.navigationBarHidden = YES;
    
    shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = shadowViewMinAlpha;
    
    [self.view addGestureRecognizer:self.m_interactivePopGestureRecognizer];
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 设置状态栏类型
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.visibleViewController preferredStatusBarStyle];
}

#pragma mark -
#pragma mark - custom method

//入栈
- (void) pushViewController:(UIViewController *)viewController
{
    [self addShadowView:viewController defaultValue:0.0f];
    
    [UIView animateWithDuration:PushPopTime
                     animations:^{
                         shadowView.alpha = shadowMax;
                     } completion:^(BOOL finished) {

                     }];

    [super pushViewController:viewController animated:YES];
    self.interactivePopGestureRecognizer.enabled = NO;
}

//出栈
- (void) popViewController
{
    //当只有一个试图控制器时，返回
    if ([self.viewControllers count] == 1) {
        return;
    }
    self.interactivePopGestureRecognizer.enabled = NO;
    [self addShadowView:self.topViewController defaultValue:shadowMax];
    
    [UIView animateWithDuration:PushPopTime
                     animations:^{
                         shadowView.alpha = 0.0;
                     }];
    [super popViewControllerAnimated:YES];
}

/**
 *  给指定的试图控制器添加阴影
 *
 *  @param viewConroller 给的试图控制器
 *  @param defaultValue  默认值
 */
- (void)addShadowView:(UIViewController *)viewConroller
         defaultValue:(CGFloat)defaultValue
{
    //确保可以加上阴影
    viewConroller.view.clipsToBounds = NO;
    
    if (![shadowView isDescendantOfView:viewConroller.view]) {
        [viewConroller.view addSubview:shadowView];
    }
    CGRect rect = shadowView.frame;
    rect.origin.x = 0;
    rect.origin.x -= SelfView_W;
    rect.size.width = SelfView_W;
    rect.size.height = SelfView_H;
    shadowView.frame = rect;
    shadowView.alpha = defaultValue;
}

/**
 *  给viewConroller.view的layer添加阴影
 *
 *  @param viewConroller 试图控制器
 */
- (void)addLayerShadowView:(UIViewController *)viewConroller
{
//    //中间的视图添加阴影
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:viewConroller.view.bounds];
//    viewConroller.view.layer.shadowPath = path.CGPath;
//    [viewConroller.view layer].shadowColor = [UIColor blackColor].CGColor;
//    [viewConroller.view layer].shadowOffset = CGSizeMake(3, 0);
//    [viewConroller.view layer].shadowOpacity = 0.7;
//    [viewConroller.view layer].shadowRadius = 3.0;
}

//全部出栈
- (void) popViewControllerToRoot
{
    if ([self.viewControllers count] == 1) {
        return;
    }
    [self addShadowView:self.topViewController defaultValue:shadowMax];
    [UIView animateWithDuration:PushPopTime
                     animations:^{
                         shadowView.alpha = 0.0;
                     }];
    self.interactivePopGestureRecognizer.enabled = NO;
    [super popToRootViewControllerAnimated:YES];
}

//跳转到制定堆栈
- (void) popToViewController:(NSString *) viewControlString
{
    if ([self.viewControllers count] == 1) {
        return;
    }
    [self addShadowView:self.topViewController defaultValue:shadowMax];
    [UIView animateWithDuration:PushPopTime
                     animations:^{
                         shadowView.alpha = 0.0;
                     }];
    self.interactivePopGestureRecognizer.enabled = NO;
    __block UIViewController *viewController = nil;
    
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([viewControlString isEqualToString:NSStringFromClass([obj class])]) {
            viewController = obj;
            *stop = YES;
        }
    }];
    
    [super popToViewController:viewController animated:YES];
}

- (void) popToDownViewController:(NSString *) viewControlString
{
    [self popToViewController:viewControlString];
}

#pragma mark -
#pragma mark - Gesture Recognizer 处理方法

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.isSlider == NO || ([self.viewControllers count] == 1 && rightwardsOutViewController == nil)) {
        return;
    }
    CGFloat translationX = [gestureRecognizer translationInView:self.view].x;
    //velocityX 为正时候向右滑动，为负时候向左滑动
    CGFloat velocityX = [gestureRecognizer velocityInView:self.view].x;
    
    //如果是向左滑动
    if (recognizerDirection == MMGestureRecognizerDirectionRight) {
        [self rightwardsPanGestureRecognizer:gestureRecognizer
                                translationX:translationX velocityX:velocityX];
    }
    else {
        [self aleftPanGestureRecognizer:gestureRecognizer
                           translationX:translationX velocityX:velocityX];
    }
}

- (void)aleftPanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
                     translationX:(CGFloat)translationX
                        velocityX:(CGFloat)velocityX
{
    UIViewController *currentViewController = self.visibleViewController;
    if (self.m_delegate == nil && [self.m_delegate respondsToSelector:@selector(pushCommentViewController)] == NO)
    {
        return;
    }
    //防止多次加载nextViewController
    if (nextViewController == nil) {
        nextViewController = [self.m_delegate pushCommentViewController];
    }
    if (nextViewController == nil) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *navView = [[self.view subviews] firstObject];
        UIView *controllerView = [[navView subviews] firstObject];
        nextViewController.view.frame = controllerView.bounds;
        if (![nextViewController.view isDescendantOfView:controllerView]) {
            [controllerView insertSubview:nextViewController.view aboveSubview:currentViewController.view];
            //中间的视图的layer添加阴影
            [self addLayerShadowView:nextViewController];
            //添加阴影view
            [self addShadowView:nextViewController defaultValue:0.0f];
        }
        nextViewController.view.center = CGPointMake(3*SelfView_W/2, CGRectGetHeight(nextViewController.view.frame)/2);
        currentViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(currentViewController.view.frame)/2);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat inViewCenterX = 3*SelfView_W/2 + translationX;
        CGFloat outViewCenterX = SelfView_W/2 + translationX/(SelfView_W/M_N_98);
        if (inViewCenterX < SelfView_W/2) {
            inViewCenterX = SelfView_W/2;
        }
        if (outViewCenterX > SelfView_W/2) {
            outViewCenterX = SelfView_W/2;
        }
        
        CGFloat shadowX = shadowMax - shadowMax *(M_N_98 + translationX/(SelfView_W/M_N_98))/M_N_98;
        shadowView.alpha = shadowX;
        nextViewController.view.center = CGPointMake(inViewCenterX, CGRectGetHeight(nextViewController.view.frame)/2);
        currentViewController.view.center = CGPointMake(outViewCenterX, CGRectGetHeight(currentViewController.view.frame)/2);
    }
    else {
        
        if (translationX > - (SelfView_W - 50)) {
            if (velocityX > 0) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    shadowView.alpha = 0.0f;
                    nextViewController.view.center = CGPointMake(3*SelfView_W/2, CGRectGetHeight(nextViewController.view.frame)/2);
                    currentViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(currentViewController.view.frame)/2);
                } completion:^(BOOL finished) {
                    [nextViewController.view removeFromSuperview];
                    nextViewController = nil;
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
                
                return;
            }
        }
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            shadowView.alpha = shadowMax;
            nextViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(nextViewController.view.frame)/2);
            currentViewController.view.center = CGPointMake(M_N_62, CGRectGetHeight(currentViewController.view.frame)/2);
        } completion:^(BOOL finished) {
            
            [nextViewController beginAppearanceTransition:YES animated:YES];
            
            [currentViewController willMoveToParentViewController:nil];
            [currentViewController beginAppearanceTransition:NO animated:YES];
            
            [currentViewController.view removeFromSuperview];
            [currentViewController endAppearanceTransition];
            
            NSMutableArray *viewCon = [self.viewControllers mutableCopy];
            [viewCon addObject:nextViewController];
            [self setViewControllers:viewCon animated:NO];
            if (IOS7AFTER) {
                //改变状态栏类型
                [nextViewController setNeedsStatusBarAppearanceUpdate];
            }
            [nextViewController endAppearanceTransition];
            nextViewController = nil;
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

- (void)rightwardsPanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
                          translationX:(CGFloat)translationX
                             velocityX:(CGFloat)velocityX
{
    UIViewController * outViewController = nil;
    UIViewController * inViewController = nil;
    if (IOS7AFTER && IOS8AFTER == NO) {
        if (rightwardsOutViewController == nil) {
            outViewController = [self.viewControllers lastObject];
            
            inViewController = self.viewControllers[([self.viewControllers count] - 2)];
            rightwardsOutViewController = outViewController;
            rightwardsInViewController = inViewController;
            
            [outViewController removeFromParentViewController];
            [inViewController removeFromParentViewController];
        }
        else {
            outViewController = rightwardsOutViewController;
            inViewController = rightwardsInViewController;
        }
    }
    else {
        outViewController = [self.viewControllers lastObject];
        
        inViewController = self.viewControllers[([self.viewControllers count] - 2)];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIView *navView = [[self.view subviews] firstObject];
        //NSLog(@"%@",[navView subviews]);
        UIView *controllerView = [[navView subviews] firstObject];
        inViewController.view.frame = controllerView.bounds;
        if ([[controllerView subviews] count] < 2) {
            [controllerView insertSubview:inViewController.view belowSubview:outViewController.view];
            //中间的视图的layer添加阴影
            [self addLayerShadowView:outViewController];
            //添加阴影view
            [self addShadowView:outViewController defaultValue:shadowMax];
        }
        inViewController.view.center = CGPointMake(M_N_62, CGRectGetHeight(inViewController.view.frame)/2);
        outViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(outViewController.view.frame)/2);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat inViewCenterX = M_N_62 + translationX/(SelfView_W/M_N_98);
        CGFloat outViewCenterX = SelfView_W/2 + translationX;
        if (inViewCenterX > SelfView_W/2) {
            inViewCenterX = SelfView_W/2;
        }
        if (outViewCenterX < SelfView_W/2) {
            outViewCenterX = SelfView_W/2;
        }
        outViewCenterX = MAX(0, outViewCenterX);
        CGFloat shadowX = shadowMax *(80 - translationX/(SelfView_W/M_N_98))/80;
        shadowView.alpha = shadowX;
        inViewController.view.center = CGPointMake(inViewCenterX, CGRectGetHeight(inViewController.view.frame)/2);
        outViewController.view.center = CGPointMake(outViewCenterX, CGRectGetHeight(outViewController.view.frame)/2);
    }
    else {
        
        if (translationX < (SelfView_W - 90)) {
            if (velocityX < 170) {
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    shadowView.alpha = shadowMax;
                    outViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(outViewController.view.frame)/2);
                    inViewController.view.center = CGPointMake(M_N_62, CGRectGetHeight(inViewController.view.frame)/2);
                } completion:^(BOOL finished) {
                    [inViewController.view removeFromSuperview];
                    if (IOS7AFTER && IOS8AFTER == NO) {
                        NSMutableArray *viewCon = [self.viewControllers mutableCopy];
                        [viewCon addObject:rightwardsInViewController];
                        [viewCon addObject:rightwardsOutViewController];
                        [self setViewControllers:viewCon animated:NO];
                        rightwardsInViewController = nil;
                        rightwardsOutViewController = nil;
                    }
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
                
                return;
            }
        }
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            shadowView.alpha = 0.0f;
            inViewController.view.center = CGPointMake(SelfView_W/2, CGRectGetHeight(inViewController.view.frame)/2);
            outViewController.view.center = CGPointMake(CGRectGetWidth(self.view.frame) + SelfView_W/2, CGRectGetHeight(outViewController.view.frame)/2);
        } completion:^(BOOL finished) {
            [inViewController beginAppearanceTransition:YES animated:YES];
            
            [outViewController willMoveToParentViewController:nil];
            [outViewController beginAppearanceTransition:NO animated:YES];
            
            [outViewController.view removeFromSuperview];
            [outViewController endAppearanceTransition];
            
            if (IOS7AFTER && IOS8AFTER == NO) {
                
            }
            else {
                [outViewController removeFromParentViewController];
            }

            if (IOS7AFTER) {
                //改变状态栏类型
                [inViewController setNeedsStatusBarAppearanceUpdate];
            }
            [inViewController endAppearanceTransition];
            if (IOS7AFTER && IOS8AFTER == NO) {
                NSMutableArray *viewCon = [self.viewControllers mutableCopy];
                [viewCon addObject:rightwardsInViewController];
                [self setViewControllers:viewCon animated:NO];
                rightwardsInViewController = nil;
                rightwardsOutViewController = nil;
            }
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [shadowView removeFromSuperview];
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.isSlider == NO) {
        return NO;
    }
    if (gestureRecognizer == self.m_interactivePopGestureRecognizer) {
        CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.view].x;
        recognizerDirection = (velocityX > 0 ? MMGestureRecognizerDirectionRight : (velocityX < 0 ? MMGestureRecognizerDirectionLeft : MMGestureRecognizerDirectionNatural));
    }
    if (gestureRecognizer == nil) {
        return NO;
    }
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

#pragma mark - getters and setters 

- (UIPanGestureRecognizer *)m_interactivePopGestureRecognizer
{
    if (_m_interactivePopGestureRecognizer == nil) {
        UIPanGestureRecognizer *_interactivePopGestureRecognizerA = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        _interactivePopGestureRecognizerA.delegate = self;
        _m_interactivePopGestureRecognizer = _interactivePopGestureRecognizerA;
    }
    return _m_interactivePopGestureRecognizer;
}

- (void)setIsSlider:(BOOL)isSlider
{
    _isSlider = isSlider;
    if (_isSlider == NO) {
        [self.view removeGestureRecognizer:self.m_interactivePopGestureRecognizer];
    }
    else {
        [self.view addGestureRecognizer:self.m_interactivePopGestureRecognizer];
    }
}

#pragma mark - 屏幕旋转设置 相关

/**
 *   @brief 添加方法 取消旋转
 *
 **/
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

@end

@implementation UIViewController (mlNav)

- (MLNavigationController *)m_nav
{
    return MMAppDelegate.nav;
}

@end