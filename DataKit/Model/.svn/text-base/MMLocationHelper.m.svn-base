//
//  MMLocationHelper.m
//  YouAsk
//
//  Created by wangyangyang on 15/7/8.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#import "MMLocationHelper.h"

@interface MMLocationHelper () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation MMLocationHelper
@synthesize userLocation = _userLocation;

- (void)startUpdatingLocation:(NSError **)error
{
    self.statusType = MMLocationStatusLoading;
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        //兼容iOS8定位
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [self.locationManager respondsToSelector:requestSelector]) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            [self.locationManager startUpdatingLocation];
        }
    }
    else {
        self.statusType = MMLocationStatusFailed;
        if (error) {
            *error = [NSError errorWithDomain:@"没找到您的位置，点击重试" code:-1 userInfo:nil];
        }
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        // iOS 7 will redundantly call this line.
        [manager startUpdatingLocation];
    } else if (status > kCLAuthorizationStatusNotDetermined) {
        //...
        [manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    self.userLocation = newLocation.coordinate;
    self.locationObject = newLocation;
    [manager stopUpdatingLocation];
    [self geocodeLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *userLocation = [locations lastObject];
    self.locationObject = userLocation;
    self.userLocation = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [manager stopUpdatingLocation];
    [self geocodeLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    self.statusType = MMLocationStatusFailed;
    if (self.c_delegate && [self.c_delegate respondsToSelector:@selector(locationHelper:didFailWithError:)]) {
        [self.c_delegate locationHelper:self didFailWithError:[NSError errorWithDomain:@"没找到您的位置，点击重试" code:-1 userInfo:nil]];
    }
}

#pragma mark - private method

- (void)geocodeLocation
{
    //创建位置  ￼//反向地理编码
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:self.locationObject completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0)
        {
            NSDictionary *dict =
            [[placemarks objectAtIndex:0] addressDictionary];
            
            NSString *_province = [NSString stringWithFormat:@"%@",[dict objectForKey:@"State"]];
            
            NSString *cityString = @"北京";
            if ([[dict objectForKey:@"City"] isEqualToString:@""] || [dict objectForKey:@"City"] == nil)
            {
                cityString = [_province stringByReplacingOccurrencesOfString:@"市" withString:@""];
            }
            else
            {
                cityString = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"City"]] stringByReplacingOccurrencesOfString:@"市" withString:@""];
            }
            self.statusType = MMLocationStatusSucceed;
            if (self.c_delegate && [self.c_delegate respondsToSelector:@selector(locationHelper:cityName:)]) {
                BOOL isSucceed = [self.c_delegate locationHelper:self cityName:cityString];
                //如果没解析成功
                if (isSucceed == NO) {
                    self.statusType = MMLocationStatusFailed;
                    if (self.c_delegate && [self.c_delegate respondsToSelector:@selector(locationHelper:didFailWithError:)]) {
                        [self.c_delegate locationHelper:self didFailWithError:[NSError errorWithDomain:@"没找到您的位置，点击重试" code:-1 userInfo:nil]];
                    }
                }
            }
            //[[NSUserDefaults standardUserDefaults] setValue:cityString forKey:@"LocationCityId"];
            
        }
        else
        {
            self.statusType = MMLocationStatusFailed;
            if (self.c_delegate && [self.c_delegate respondsToSelector:@selector(locationHelper:didFailWithError:)]) {
                [self.c_delegate locationHelper:self didFailWithError:[NSError errorWithDomain:@"没找到您的位置，点击重试" code:-1 userInfo:nil]];
            }
            //[[NSUserDefaults standardUserDefaults] setValue:@"北京" forKey:@"LocationCityId"];
        }
    }];
}

#pragma mark - getters and setters

- (void)setUserLocation:(CLLocationCoordinate2D)userLocation
{
    _userLocation = userLocation;
    if ((NSInteger)_userLocation.latitude > 0) {
        //保存到userDefault里面
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@||%@",[@(userLocation.latitude) stringValue], [@(userLocation.longitude) stringValue]] forKey:@"YouWenUserLocation_MMLocationHelper"];
        //end
    }
}

- (CLLocationCoordinate2D)userLocation
{
    if ((NSInteger)_userLocation.latitude <= 0) {
        //读取用户上次的位置
        NSString *youWenUserLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"YouWenUserLocation_MMLocationHelper"];
        if (youWenUserLocation) {
            NSArray *youWenUserLocationArray = [youWenUserLocation componentsSeparatedByString:@"||"];
            _userLocation.latitude = [[youWenUserLocationArray firstObject] doubleValue];
            _userLocation.longitude = [[youWenUserLocationArray lastObject] doubleValue];
        }
        //end
    }
    return _userLocation;
}

@end
