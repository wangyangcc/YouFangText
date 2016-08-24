//
//  MMLocationHelper.h
//  YouAsk
//
//  Created by wangyangyang on 15/7/8.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMLocationStatusType) {

    MMLocationStatusLoading = 1, //定位中

    MMLocationStatusFailed, //定位失败

    MMLocationStatusSucceed, //定位成功
};

@protocol MMLocationHelperDelegate;
@interface MMLocationHelper : NSObject

@property (strong, nonatomic) CLLocation *locationObject;
@property (assign, nonatomic) CLLocationCoordinate2D userLocation;

@property (assign, nonatomic) MMLocationStatusType statusType;

@property (weak, nonatomic) id<MMLocationHelperDelegate> c_delegate;

- (void)startUpdatingLocation:(NSError **)error;

@end

@protocol MMLocationHelperDelegate <NSObject>

- (void)locationHelper:(MMLocationHelper *)helper
      didFailWithError:(NSError *)error;

- (BOOL)locationHelper:(MMLocationHelper *)helper
      cityName:(NSString *)cityName;

@end
