//
//  AFCircleChart.h
//  GraphicsDemo
//
//  Created by Anthony Fennell on 3/4/15.
//  Copyright (c) 2015 Anthony Fennell. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////
//
//  This is a circle chart that is represented by the curve around
//  the circle as a percentage of a given (value / total).
//
//  Initialize first - (Interface Builder or initWithFrame or all in one
//  initWithFrame:lineWidth:atValue:totalValue:color
//
//  Second setUpLineWidth:atValue:totalValue:color - Used to set up
//  parameters if they have not been set up.
//
//  Next call animatePath - This method will initialize all layers of the
//  chart and animate the chart based on the input values.
//
//  Finally - If the "value" or "total" parameters need to be changed then a
//  call to (reAnimateChartWithValue:total:) will remove the top layers of
//  the chart and reconstruct new layers with the new input values.
//
/////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>

@class AFCircleChart;
@protocol AFCircleChartDelegate <NSObject>
/// Delegate method for tracking touch events
- (void)touchedCircleChart:(AFCircleChart *)sender;
@end


@interface AFCircleChart : UIView

/// Color of background circle
@property (strong, nonatomic) UIColor *bottomLayerColor;

@property (nonatomic, weak) id <AFCircleChartDelegate> delegate;

#pragma mark - Initialization

/// Initialize and set up parameter values
- (instancetype)initWithFrame:(CGRect)frame lineWidth:(NSInteger)width chartImage:(NSString *)chartImage;

- (void)setChartImage:(NSString *)chartImage;
- (void)setTextIconImage:(NSString *)textIconImage;

- (void)setAtValue:(NSInteger)value
        totalValue:(NSInteger)total;

//label会居中显示
- (void)setLabelAttributedString:(NSMutableAttributedString *)attributedString
                      labelFrame:(CGRect)labelFrame;

#pragma mark - Animation

//  Animate Path must be called to draw chart and before any reAnimate calls
/// Draw / Animate the chart
- (void)animatePath;
/// Re-Animate chart with new value and total value
- (void)reAnimateChartAtValue:(NSInteger)value totalValue:(NSInteger)total;
/// Re-Animate / draw chart with new value
- (void)reAnimateChartatValue:(NSInteger)value;
/// Re-Animate / draw chart with new total value
- (void)reAnimateChartatTotalValue:(NSInteger)total;

@end









