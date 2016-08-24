//
//  A3ParallaxScrollView.h
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
//

#import <UIKit/UIKit.h>


/// default acceleration Behaviour is CGGoint{1.0f, 1.0f}
extern CGPoint const A3DefaultAcceleration;


@interface A3ParallaxScrollView : UIScrollView

/**
 @description Adds a Subview to the Scrollview with a specific acceleration.
 @param view The View wich will be added as subview.
 @param acceleration Acceleration of a View. ScrollViews default behaviour is CGPoint{1.0f, 1.0f} (via [addSubview]).
 */
- (void)addSubview:(UIView *)view withAcceleration:(CGPoint) acceleration;


/**
 @description Sets the acceleration of an Subview.
 @param acceleration Acceleration of a View. ScrollViews default behaviour is CGPoint{1.0f, 1.0f} (via [addSubview]).
 @param view The View wich acceleration will be set.
 */
- (void)setAcceleration:(CGPoint) acceleration forView:(UIView *)view;


/**
 @description Gets the acceleration for a subview.
 @return acceleration Acceleration of the specified View.
 @param view The View wich acceleration should be returned.
 */
- (CGPoint)accelerationForView:(UIView *)view;

@end
