//
//  AFCircleChart.m
//  GraphicsDemo
//
//  Created by Anthony Fennell on 3/4/15.
//  Copyright (c) 2015 Anthony Fennell. All rights reserved.
//

#import "AFCircleChart.h"

#define degreesToRadians(x) ((x) * M_PI / 180.0)

static NSString * const topLayerString = @"topLayer";
static NSString * const bottomLayerString = @"bottomLayer";


@interface AFCircleChart ()

/// Color of circle
@property (copy, nonatomic) NSString *topLayerImage;

/// Reference to background layer to redraw top layer
@property (nonatomic, weak) CAShapeLayer *bottomLayer;
@property (nonatomic, weak) CALayer *textIconLayer;
@property (copy, nonatomic) NSString *textIconLayerImage;
/// Reference to top layer of view
@property (nonatomic, weak) CALayer *topLayer;

/// Point on graph to be displayed as a percentage around the chart
@property (nonatomic) NSInteger value;
/// Total value or maximum value to be obtained by graph
@property (nonatomic) NSInteger total;
/// Width of the circle
@property (nonatomic) NSInteger lineWidth;

/// Start angle(degrees) that the graph starts at
@property (nonatomic) double startAngle;
/// End angle(degrees) that the graph reaches around the circle
@property (nonatomic) double endAngle;
/// Radius of circle
@property (nonatomic) double radius;
/// Center point of chart and view
@property (nonatomic) CGPoint centerOfChart;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSMutableAttributedString *labelAttributedString;
@property (nonatomic, assign) CGRect labelFrame;

@end

@implementation AFCircleChart

@synthesize delegate;

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // Very light gray color
        self.bottomLayerColor = [UIColor colorWithRed:240/255.0 green:240/255.0
                                                      blue:240/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame lineWidth:0 chartImage:nil];
}

// Initializer
- (instancetype)initWithFrame:(CGRect)frame lineWidth:(NSInteger)width chartImage:(NSString *)chartImage
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.bottomLayerColor = [UIColor colorWithRed:240/255.0 green:240/255.0
                                                 blue:240/255.0 alpha:1.0];
        self.lineWidth = width;
        self.topLayerImage = chartImage;
        
        [self setParameterValues];
        [self setStartAndEndAngles];
        [self drawBackgroundCircle];
    }
    return self;
}

#pragma mark - Touches Ended fire Delegate

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([delegate respondsToSelector:@selector(touchedCircleChart:)]) {
        [self.delegate touchedCircleChart:self];
    }
}

#pragma mark - Setter methods

- (void)setLineWidth:(NSInteger)width atValue:(NSInteger)value
          totalValue:(NSInteger)total chartImage:(NSString *)chartImage
   descriptionString:(NSString *)string
{
    self.lineWidth = width;
    self.value = value;
    self.total = total;
    self.topLayerImage = chartImage;
    [self setParameterValues];
}

- (void)setChartImage:(NSString *)chartImage
{
    self.topLayerImage = chartImage;
}

- (void)setTextIconImage:(NSString *)textIconImage
{
    self.textIconLayerImage = textIconImage;
    self.textIconLayer.contents = (id)[UIImage imageNamed:textIconImage].CGImage;
}

- (void)setAtValue:(NSInteger)value
        totalValue:(NSInteger)total
{
    self.value = value;
    self.total = total;
}

- (void)setLabelAttributedString:(NSMutableAttributedString *)attributedString
                      labelFrame:(CGRect)labelFrame
{
    self.labelAttributedString = attributedString;
    self.labelFrame = labelFrame;
    [self createTextInCenterOfCircle];
}

- (void)setBottomLayerColor:(UIColor *)bottomLayerColor
{
    _bottomLayerColor = bottomLayerColor;
    self.bottomLayer.strokeColor = bottomLayerColor.CGColor;
}

#pragma mark - Animation methods

/*  
 *  Animation method. Sets background of chart.
 *  All re-Animate methods will leave the background as is and
 *  animate the rest of the chart
 */
- (void)animatePath
{
    [self setParameterValues];
    [self setStartAndEndAngles];
    [self createTextInCenterOfCircle];
    if (self.value > 0) {
        [self drawTopLayerAndAnimate];
    }
}

- (void)reAnimateChartAtValue:(NSInteger)value totalValue:(NSInteger)total
{
    self.value = value;
    self.total = total;
    
    [self.topLayer removeFromSuperlayer];
    [self.label removeFromSuperview];
    
    [self setStartAndEndAngles];
    [self createTextInCenterOfCircle];
    
    if (self.value > 0) {
        [self drawTopLayerAndAnimate];
    }
}

- (void)reAnimateChartatValue:(NSInteger)value
{
    [self reAnimateChartAtValue:value totalValue:self.total];
}

- (void)reAnimateChartatTotalValue:(NSInteger)total
{
    [self reAnimateChartAtValue:self.value totalValue:total];
}



#pragma mark - Private Helper methods

/// Set radius and center value of chart
- (void)setParameterValues
{
    CGPoint center;
    center.x = self.bounds.origin.x + self.bounds.size.width / 2.0;
    center.y = self.bounds.origin.y + self.bounds.size.height / 2.0;
    self.centerOfChart = center;
    
    // The circle will be the largest that will fit in the view
    if (self.bounds.size.width == self.bounds.size.height) {
        _radius = (self.bounds.size.width - self.lineWidth) / 2.0;
    } else if (self.bounds.size.width < self.bounds.size.height) {
        _radius = (self.bounds.size.width - self.lineWidth) / 2.0;
    } else {
        _radius = (self.bounds.size.height - self.lineWidth) / 2.0;
    }
}

/// Draw the top layer of chart and animate the path
- (void)drawTopLayerAndAnimate
{
    if (self.topLayerImage == nil) {
        return;
    }
    UIBezierPath *path = [[UIBezierPath alloc] init];
    NSInteger value = 1;
    [path moveToPoint:CGPointMake(self.centerOfChart.x + value, self.centerOfChart.y - self.radius)];

    if (self.value < self.total) {
        
        [path addArcWithCenter:self.centerOfChart radius:self.radius
                    startAngle:degreesToRadians(self.startAngle)
                      endAngle:degreesToRadians(self.endAngle) clockwise:YES];
    } else {
        // If (value > total) then the entire chart must be filled.
        // Therefore, two arcs must be connected otherwise the entire circle
        // won't connect if using M_PI*3/2 as start and end angle
        UIBezierPath *addedPath = [[UIBezierPath alloc] init];
        [path addArcWithCenter:self.centerOfChart radius:self.radius
                    startAngle:degreesToRadians(self.startAngle)
                      endAngle:0 clockwise:YES];
        [addedPath addArcWithCenter:self.centerOfChart radius:self.radius
                    startAngle:0 endAngle:degreesToRadians(self.startAngle) clockwise:YES];
        [path appendPath:addedPath];
    }
    path.lineWidth = self.lineWidth;
    
    CAShapeLayer *topLayer = [CAShapeLayer layer];
    topLayer.path = path.CGPath;
    topLayer.lineWidth = self.lineWidth;
    topLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    topLayer.fillColor = [UIColor clearColor].CGColor;
    topLayer.name = topLayerString;
    topLayer.lineCap = kCALineCapRound;
    
    //背景圈圈图层
    CALayer *layerTwo = [[CALayer alloc] init];
    layerTwo.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    layerTwo.contents = (id)[UIImage imageNamed:self.topLayerImage].CGImage;
    [layerTwo setMask:topLayer];
    [self.bottomLayer addSublayer:layerTwo];
    self.topLayer = layerTwo;
    //end
    
    //  ANIMATE
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    anim1.fromValue = [NSNumber numberWithFloat:0.1f];
    anim1.toValue = [NSNumber numberWithFloat:1.0f];
    // Makes the animation repeat once
    anim1.repeatCount = 1.0;
    anim1.duration = 1.5;
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [topLayer addAnimation:anim1 forKey:@"drawCircleAnimation"];
}

/// Draw the background circle of chart
- (void)drawBackgroundCircle
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CAShapeLayer *bottomLayer = [CAShapeLayer layer];
    
    [path moveToPoint:CGPointMake(self.centerOfChart.x + self.radius, self.centerOfChart.y)];
    [path addArcWithCenter:self.centerOfChart radius:self.radius
                startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = self.lineWidth;
    
    bottomLayer.path = path.CGPath;
    bottomLayer.lineWidth = self.lineWidth;
    bottomLayer.name = bottomLayerString;
    
    bottomLayer.strokeColor = self.bottomLayerColor.CGColor;
    bottomLayer.fillColor = [UIColor clearColor].CGColor;
    [[self layer] addSublayer:bottomLayer];
    self.bottomLayer = bottomLayer;
    
    //文字背景
    CALayer *layer = [CALayer new];
    layer.frame = CGRectMake(CGRectGetWidth(self.frame)/2, 0, 57, 30);
    layer.contents = (id)[UIImage imageNamed:self.textIconLayerImage].CGImage;
    [[self layer] addSublayer:layer];
    self.textIconLayer = layer;
    //end
}

/// Find the start and end angles of where the chart starts and stops
- (void)setStartAndEndAngles
{
    self.startAngle = 270;
    
    if (self.value > self.total) {
        return;
    } else if (self.value == 0) {
        self.endAngle = 270;
        return;
    }
    
    float angle = self.value / (float)self.total * 360;
    
    if (angle < 90) {
        self.endAngle = self.startAngle + angle;
    } else {
        angle -= 90;
        self.endAngle = angle;
    }
}

/// Create text values displayed in the center of chart
- (void)createTextInCenterOfCircle
{
    if (self.label) {
        [self.label removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.labelFrame;
    label.attributedText = self.labelAttributedString;
    [self addSubview:label];
    self.label = label;
}

@end
