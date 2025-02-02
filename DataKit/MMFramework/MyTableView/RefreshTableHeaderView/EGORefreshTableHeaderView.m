//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

#define DOWNDRAGFRESH @"下拉刷新"
#define RELEASEFRESH @"释放刷新"
#define LOADINGFRESH @"加载中..."
#define DONEFRESH @"加载完成"


#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView()

- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        loadingView = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(112 + ScreenWidthAdd/2, frame.size.height - 40, 26, 26)];
        [self addSubview:loadingView];
        
        loadingView.progressTotal = 63;
        loadingView.progressCounter = 0;
        loadingView.theme.thickness = 6;
        loadingView.theme.incompletedColor = [UIColor clearColor];
        loadingView.theme.completedColor = DKNavbackcolor;
        loadingView.theme.sliceDividerHidden = YES;
        loadingView.label.hidden = YES;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(145.0f + ScreenWidthAdd/2, frame.size.height - 40, 175, 25.0f)];
		label.font = [UIFont systemFontOfSize:15.0f];
		label.textColor = [UIColor lightGrayColor];
        label.alpha = 0.7f;
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
        label.text = DOWNDRAGFRESH;
		_statusLabel=label;
        
        _state = EGOOPullRefreshNormal;
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters
- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			_statusLabel.text = RELEASEFRESH;
			
			break;
		case EGOOPullRefreshNormal:
			
			_statusLabel.text = DOWNDRAGFRESH;
            [self removeAnimation];
            
			break;
		case EGOOPullRefreshLoading:
        {            
			_statusLabel.text = LOADINGFRESH;
            [self addAnimation];
        }
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

//动画的暂停与开始
- (void)addAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//动画继续
- (void)removeAnimation
{
    [loadingView.layer removeAnimationForKey:@"rotationAnimation"];
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    //60不让圆圈画满
    CGFloat offY = fabs(scrollView.contentOffset.y);
    if (offY > 60)
    {
        offY = 60;
    }
    
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)])
    {
        _loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
    }
    
    if (_state != EGOOPullRefreshLoading)
    {
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -60.0f && scrollView.contentOffset.y < 0.0f && !_loading)
        {
			[self setState:EGOOPullRefreshNormal];
		}
        else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -60.0f && !_loading)
        {
			[self setState:EGOOPullRefreshPulling];
		}
	}
    
    loadingView.progressCounter = offY;
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [self.delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 60.0f && !_loading) {
		
		if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[self.delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView 
{
    _state = EGOOPullRefreshNormal;
    _statusLabel.text = DONEFRESH;
    
	if (scrollView)
    {
        [UIView animateWithDuration:0.4 animations:^{
            if (scrollView.contentOffset.y < 0)
            {
                [scrollView setContentOffset:CGPointMake(0, 0)];
            }
            
            scrollView.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
            
        } completion:^(BOOL finished) {
            [self setState:EGOOPullRefreshNormal];
            
            
        }];
    }
}

#pragma mark - lcc
- (void) customSetState:(EGOPullRefreshState)aState
{
    if (aState == EGOOPullRefreshLoading)
    {
        loadingView.progressCounter = 60;
    }
    else
    {
        loadingView.progressCounter = 1;
    }
    
    [self setState:aState];
}


@end
