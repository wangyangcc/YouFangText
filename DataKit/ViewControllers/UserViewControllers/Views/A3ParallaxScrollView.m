//
//  A3ParallaxScrollView.m
//  A3ParallaxScrollViewSample
//
//  A3ParallaxScrollView for iOS
//  Created by Botond Kis on 24.10.12.
//  Copyright (c) 2012 aaa - All About Apps
//  Developed by Botond Kis
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:


#import "A3ParallaxScrollView.h"

CGPoint const A3DefaultAcceleration = (CGPoint){1.0f, 1.0f};

@interface A3ParallaxScrollView ()
@property (nonatomic, retain) NSMutableDictionary *_accelerationsOfSubViews;

- (void)_init;

@end

@implementation A3ParallaxScrollView
@synthesize _accelerationsOfSubViews;

//====================================================================
#pragma mark - memory & initialization

// designated init
- (void)_init{
    _accelerationsOfSubViews = [[NSMutableDictionary alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)dealloc{
    _accelerationsOfSubViews = nil;
}


//====================================================================
#pragma mark - logic

- (void)addSubview:(UIView *)view{
    [self addSubview:view withAcceleration:A3DefaultAcceleration];
}


- (void)addSubview:(UIView *)view withAcceleration:(CGPoint) acceleration{
    // add to super
    [super addSubview:view];
    [self setAcceleration:acceleration forView:view];
}


- (void)setAcceleration:(CGPoint) acceleration forView:(UIView *)view{
    // store acceleration
    NSValue *pointValue = [NSValue value:&acceleration withObjCType:@encode(CGPoint)];
    [self._accelerationsOfSubViews setObject:pointValue forKey:@((int)view)];
}

- (CGPoint)accelerationForView:(UIView *)view{
    
    // return
    CGPoint accelecration;
    
    // get acceleration
    NSValue *pointValue = [self._accelerationsOfSubViews objectForKey:@((int)view)];
    if(pointValue == nil){
        accelecration = CGPointZero;
    }
    else{
        [pointValue getValue:&accelecration];
    }
    
    return accelecration;
}

- (void)willRemoveSubview:(UIView *)subview{
    [self._accelerationsOfSubViews removeObjectForKey:@((int)subview)];
}

//====================================================================
#pragma mark - layout

- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *v in self.subviews) {
        // get acceleration
        CGPoint accelecration = [self accelerationForView:v];
        
        //单独设置 星空间里面的 背景大图 位移
        if (accelecration.y == - 100000) {
            v.transform = CGAffineTransformMakeScale(self.contentOffset.x,self.contentOffset.y);
            return;
        }
        
        // move the view
        v.transform = CGAffineTransformMakeTranslation(self.contentOffset.x*(1.0f-accelecration.x), self.contentOffset.y*(1.0f-accelecration.y));
    }
}

@end
