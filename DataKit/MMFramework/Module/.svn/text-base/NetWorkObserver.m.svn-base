//
//  NetWorkObserver.m
//  ZhongGuoWangShi
//
//  Created by mmc on 13-7-18.
//
//

#import "NetWorkObserver.h"

@implementation NetWorkObserver

+ (int)dataNetworkTypeFromStatusBar {
	
	
	
	UIApplication *app = [UIApplication sharedApplication];
	
	NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
	
	NSNumber *dataNetworkItemView = nil;
	
	
	
	for (id subview in subviews) {
		
		if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
			
			dataNetworkItemView = subview;
			
			break;
			
		}
		
	}
	
	
	
	int netType = NETWORK_TYPE_NONE;
	
	NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
	
	if (num == nil)
	{
		netType = NETWORK_TYPE_NONE;

	}
	else
	{
		
		int n = [num intValue];
		
		if (n == 0)
        {
			netType = NETWORK_TYPE_NONE;
		}
        else if (n == 1)
        {
            netType = NETWORK_TYPE_2G;
		}
        else if (n == 2)
        {
			netType = NETWORK_TYPE_3G;
		}
        else
        {
			netType = NETWORK_TYPE_WIFI;
		}
	}

	return netType;
	
}

+ (BOOL) isSetImageViewVisible
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int isVisible = [userDefault objectForKey:@"isLoad"] == nil?1:[[userDefault objectForKey:@"isLoad"] intValue];
    
    if ([self dataNetworkTypeFromStatusBar] == NETWORK_TYPE_WIFI || ([self dataNetworkTypeFromStatusBar] != NETWORK_TYPE_WIFI && isVisible == 1))
    {
        //加载图片
        return YES;
    }
    else
    {
        //不加在图片
        return NO;
    }
}

@end
