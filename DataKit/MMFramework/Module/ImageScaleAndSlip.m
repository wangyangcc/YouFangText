//
//  ImageScaleAndSlip.m
//  D5Media
//
//  Created by mmc on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageScaleAndSlip.h"

#import "ImageScaleAndSlip.h"

@implementation ImageScaleAndSlip

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.delegate = self;
        self.maximumZoomScale = 2.5;
        self.minimumZoomScale = 1.0;
        self.bouncesZoom = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.imageView  = [[ScaleAndSlipImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setImagePath:(NSString *)imageStr
{
    [self.imageView setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@""]];
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.imageView.frame;
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    
    self.imageView.center = centerPoint;
}

#pragma mark -
#pragma mark === UITouch Delegate ===
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    switch (touch.tapCount) {
        case 1:
            [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.5];
            break;
        case 2:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            [self performSelector:@selector(doubleTap:) withObject:NSStringFromCGPoint(touchPoint) afterDelay:0];
        default:
            break;
    }
}

-(void)singleTap
{
    
    if (self.scale_slip_delegate != nil && [self.scale_slip_delegate respondsToSelector:@selector(imageScaleAndSliDelegateTapOne)])
    {
        [self.scale_slip_delegate imageScaleAndSliDelegateTapOne];
    }
}
-(void)doubleTap:(NSString *)pointString
{
    CGPoint touchPoint = CGPointFromString(pointString);
    // Zoom
    if (self.zoomScale == self.maximumZoomScale) {
        
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        
    }
}

@end

@implementation ScaleAndSlipImageView

- (void)setImage:(UIImage *)image
{
    CGRect superViewRect = self.superview.frame;
    UIScrollView *superView = (UIScrollView *)self.superview;
    if (image)
    {
        CGSize imgSize = CGSizeMake(0, 0);
        CGRect scaleOriginRect = CGRectMake(0, 0, 0, 0);
        imgSize = image.size;
        
        //判断首先缩放的值
        float scaleX = superViewRect.size.width/imgSize.width;
        float scaleY = superViewRect.size.height/imgSize.height;
        
        //倍数小的，先到边缘
        
        if (scaleX > scaleY)
        {
            //Y方向先到边缘
            float imgScreenWidth = imgSize.width*scaleY;
            superView.maximumZoomScale = superViewRect.size.width/imgScreenWidth;
            scaleOriginRect = (CGRect){superViewRect.size.width/2-imgScreenWidth/2,0,imgScreenWidth,superViewRect.size.height};
        }
        else
        {
            //X先到边缘
            float imgScreenHeight = imgSize.height*scaleX;
            superView.maximumZoomScale = superViewRect.size.height/imgScreenHeight;
            scaleOriginRect = (CGRect){0,superViewRect.size.height/2-imgScreenHeight/2,superViewRect.size.width,imgScreenHeight};
        }
        
        self.frame = scaleOriginRect;
    }
    [super setImage:image];
}
@end
