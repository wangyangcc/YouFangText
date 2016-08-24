//
//  ImageScaleAndSlip.h
//  D5Media
//
//  Created by mmc on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+MMSDWebImageView.h"

@protocol ImageScaleAndSliDelegate;
@class ScaleAndSlipImageView;

@interface ImageScaleAndSlip : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) NSString *imagePath;
@property (weak) id<ImageScaleAndSliDelegate> scale_slip_delegate;
@property (nonatomic, strong) ScaleAndSlipImageView *imageView;

@end


@protocol ImageScaleAndSliDelegate <NSObject>

- (void) imageScaleAndSliDelegateTapOne;

@end

@interface ScaleAndSlipImageView : UIImageView

@end