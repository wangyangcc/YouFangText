//
//  MetaData.m
//  zuiwuhan
//
//  Created by mmc on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MetaData.h"

//#import "JSON.h"
#import "UIDeviceHardware.h"
#import "UIDevice+IdentifierAddition.h"
#import "AppDelegate.h"
#import "NSString+URLEncoding.h"
#import "MMPushManager.h"

@implementation MetaData

+ (NSString*) getPlatform
{
    NSString* platform = [UIDeviceHardware platformString];
    
    platform = [platform stringByReplacingOccurrencesOfString:@"(" withString:@""];
    platform = [platform stringByReplacingOccurrencesOfString:@")" withString:@""];
    platform = [platform stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [platform copy];
}

+ (NSString*) getOSVersion
{
    NSString* osVersion = [NSString stringWithFormat:@"%@",
                           [[UIDevice currentDevice] systemVersion]];
    NSArray *arr = [osVersion componentsSeparatedByString:@"."];
    osVersion = [arr objectAtIndex:0];
    return [osVersion copy];
}

+ (NSString*) getLongOSVersion
{
    NSString* osVersion = [NSString stringWithFormat:@"iOS %@",
                           [[UIDevice currentDevice] systemVersion]];
    return [osVersion copy];
}

+ (NSString*) getUid
{
    if ([[MetaData getOSVersion] floatValue] >= 7.0)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:@"uuid"] == nil)
        {
            CFUUIDRef puuid = CFUUIDCreate( nil );
            CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
            NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
            CFRelease(puuid);
            CFRelease(uuidString);
            [userDefaults setObject:result forKey:@"uuid"];//保存UUID
            [userDefaults synchronize];
            
            return [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"uuid"]];
        }
        else
        {
            return [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"uuid"]];
        }
        
        return nil;
    }
    NSString* uid = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];
    
    return [uid copy];
}

+ (NSString*) getCurrVer
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *currVer = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    return [currVer copy];
}

+ (NSString*) getSid
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *sid = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    return [sid copy];
}

+ (NSString*) getImei
{
    return @"";
}

+ (NSString*) getImsi
{
    return @"";
}

+ (NSString*) getVerCode
{
    return [self getCurrVer];
}

+ (NSString*) getVerName
{
    return [self getCurrVer];
}

BOOL isJailBreak()
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
    {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
    {
        jailbroken = YES;
    }  
    return jailbroken;
}

+ (NSString *) getIsJail
{
    return [NSString stringWithFormat:@"%d",isJailBreak()];
}

+ (NSString *) getToken
{
    return [MMPushManager getPushToken];
}

+ (NSString *) getNetworkToken //获取token
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    return [NSString stringWithFormat:@"%@",token];
}

/**
 *  是否是 3.5寸屏幕
 *
 *  @return 结果
 */
+ (BOOL) isIphone4_4s
{
    return (NSInteger)ScreenWidth <= 320 && (NSInteger)ScreenHeight <= 480;
}

/**
 *  是否是 4寸屏幕
 *
 *  @return 结果
 */
+ (BOOL) isIphone5_5s
{
    return (NSInteger)ScreenWidth <= 320 && (NSInteger)ScreenHeight > 480;
}

/**
 *  是否是6 plus
 *
 *  @return 结果
 */
+ (BOOL) isIphone6plus
{
    return ScreenWidth >= 414;
}

/**
 *  是否是6
 *
 *  @return 结果
 */
+ (BOOL) isIphone6
{
    return (NSInteger)ScreenWidth == 375;
}

/**
 *  为不同的设备，设置不同的值
 *
 *  @param cun3_5 3.5寸屏幕
 *  @param cun4   4寸屏幕
 *  @param cun4_7 4.7寸屏幕
 *  @param cun5_5 5.5寸屏幕
 *
 *  @return 值
 */
+ (CGFloat)valueForDeviceCun3_5:(CGFloat)cun3_5
                           cun4:(CGFloat)cun4
                         cun4_7:(CGFloat)cun4_7
                         cun5_5:(CGFloat)cun5_5
{
    //4寸以上屏幕
    if ((NSInteger)ScreenWidth > 320) {
        if ((NSInteger)ScreenWidth <= 375) {
            return cun4_7;
        }
        else {
            return cun5_5;
        }
    }
    else {
        if ((NSInteger)ScreenHeight <= 480) {
            return cun3_5;
        }
        else {
            return cun4;
        }
    }
    return 0;
}

+ (NSString *)getBundleId
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *sid = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    return [sid copy];
}

+(NSArray *) getResolution
{
    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    
    NSString *width = [NSString stringWithFormat:@"%g",rect_screen.size.width*scale_screen];
    NSString *height = [NSString stringWithFormat:@"%g",rect_screen.size.height*scale_screen];
    
    return [NSArray arrayWithObjects:width, height, nil];
}

+ (NSString *) getNowSecondsDate
{
    NSDate *date = [NSDate dk_date];
    
    [date timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%0.0f",[date timeIntervalSince1970]];
}

+(void) writeFile:(NSString *) filePath data:(NSString *) _data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* fileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:filePath];
    
    
    // 用这个方法来判断当前的文件是否存在，如果不存在，就创建一个文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( ![fileManager fileExistsAtPath:fileName]) {
        NSLog(@"File %@ not exists!", fileName);
        [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    }else NSLog(@"File %@ exists!", fileName);
    
    NSLog(@"File %@ will write!", fileName);
    [_data writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(NSString *) readFile:(NSString *) filePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* fileName = [[paths objectAtIndex:0]stringByAppendingPathComponent:filePath];
    NSLog(@"File %@ will be read!", fileName);
    
    NSString* myString = [NSString stringWithContentsOfFile:fileName usedEncoding:NULL error:NULL];
    return myString;
}

+ (NSInteger)getTs{
    NSDate *date = [NSDate dk_date];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    
    return (NSInteger) timestamp;
}

+(NSString*) writeFileToDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename data:(NSData *) data{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains((type==0?NSDocumentDirectory:(type==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    NSString* spath =[paths objectAtIndex:0];
    [fileManager changeCurrentDirectoryPath:spath];
    if(dirname.length>0){
        [fileManager createDirectoryAtPath:dirname withIntermediateDirectories:YES attributes:nil error:nil];
        spath = [NSString stringWithFormat:@"%@/%@/%@", spath, dirname, filename];
    }else
        spath = [NSString stringWithFormat:@"%@/%@", spath, filename];
    
    [fileManager createFileAtPath:spath contents:data attributes:nil];
    return spath;
}

+(NSData*) readFileFromDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains((type==0?NSDocumentDirectory:(type==1?NSLibraryDirectory:NSCachesDirectory)), NSUserDomainMask, YES);
    NSString* spath =[paths objectAtIndex:0];
    
    if(dirname.length>0)
        spath = [NSString stringWithFormat:@"%@/%@/%@", spath, dirname, filename];
    else
        spath = [NSString stringWithFormat:@"%@/%@", spath, filename];
    
    return [[NSData alloc] initWithContentsOfFile:spath];
}
@end
