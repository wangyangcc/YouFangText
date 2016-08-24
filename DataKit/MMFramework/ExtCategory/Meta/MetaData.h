//
//  MetaData.h
//  zuiwuhan
//
//  Created by mmc on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaData : NSObject

+ (NSString *) getPlatform;
+ (NSString *) getOSVersion;
+ (NSString *) getLongOSVersion;
+ (NSString *) getUid;

+ (NSString *) getCurrVer;
+ (NSString *) getSid;

+ (NSString *) getImei;
+ (NSString *) getImsi;

+ (NSString *) getVerCode;
+ (NSString *) getVerName;//获取版本名字

+ (NSString *) getIsJail;//获取是否越狱

+ (NSString *) getToken;//获取token

+ (NSArray *) getResolution;//获取分辨率

+ (NSString *) getNowSecondsDate;//获取当前时间戳

//+ (NSString *)requestJSON;

+ (NSString *) getNetworkToken;//获取token

/**
 *  是否是 3.5寸屏幕
 *
 *  @return 结果
 */
+ (BOOL) isIphone4_4s;

/**
 *  是否是 4寸屏幕
 *
 *  @return 结果
 */
+ (BOOL) isIphone5_5s;

/**
 *  是否是6 plus
 *
 *  @return 结果
 */
+ (BOOL) isIphone6plus;

/**
 *  是否是6
 *
 *  @return 结果
 */
+ (BOOL) isIphone6;

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
                         cun5_5:(CGFloat)cun5_5;

+ (NSString *)getBundleId;

+(void) writeFile:(NSString *) filePath data:(NSString *) _data;
+(NSString *) readFile:(NSString *) filePath;

+(NSInteger)getTs;

+(NSString*) writeFileToDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*)filename data:(NSData *) data;
+(NSData*) readFileFromDirWithDirType:(NSString*) dirname dirType:(NSInteger) type fileName:(NSString*) filename;

@end
