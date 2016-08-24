//
//  DKSorcketRequestHelper.m
//  DataKit
//
//  Created by wangyangyang on 15/12/6.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import "DKSocketRequestHelper.h"
#import "AsyncSocket.h"
#import "JSONKit.h"
#import "NSObject+LogDealloc.h"
#import "SDWebImageCompat.h"
#import "NSString+extras.h"

@interface DKSocketRequestHelper () <AsyncSocketDelegate>
{
    AsyncSocket *socket;
    long currentReuqestTag; /** 当前操作的tag*/
    long connectTag; /** 当前连接服务器中的tag*/
    
    BOOL isConnecting;/** 是否在连接中 */
}

@property (nonatomic, strong) NSMutableDictionary *requestTags;

@property (nonatomic, strong) NSMutableDictionary *responseData; //** 如果一次没有接受完，则放到这个字典里面，继续接受 */

@property (nonatomic, strong) NSMutableDictionary *responseTags;

@end

@implementation DKSocketRequestHelper

+ (instancetype)Helper
{
    static dispatch_once_t one_t;
    static DKSocketRequestHelper *_shareHelper;
    dispatch_once(&one_t, ^{
        _shareHelper = [[DKSocketRequestHelper alloc] init];
        _shareHelper.responseSerializer = [DKSocketResponseSerialization new];
    });
    return _shareHelper;
}

- (void)socketRequestWithParameters:(id)parameters
                         requestTag:(long)requestTag
                             result:(void (^)(id responseObject, NSError *error))result
{
    //处理参数
    if (parameters == nil) {
        parameters = @"";
    }
    if (requestTag <= 0 || result == NULL) {
        return;
    }
    //end

    [self.requestTags setValue:parameters forKey:[@(requestTag) stringValue]];
    [self.responseTags setValue:[result copy] forKey:[@(requestTag) stringValue]];
    
    connectTag = requestTag;
    if ([self isConnected]) {
        connectTag = 0;
        [self beginSendData];
    }
}

//清空请求，根据tag
- (void)clearRequestWithRequestTag:(long)requestTag
{
    //当正在执行的时候，不清空
    if (requestTag == 0 || currentReuqestTag == requestTag) {
        return;
    }
    [self.requestTags removeObjectForKey:[@(requestTag) stringValue]];
    [self.responseTags removeObjectForKey:[@(requestTag) stringValue]];
}

- (BOOL)isConnected
{
    if (socket == nil) {
        socket = [[AsyncSocket alloc] initWithDelegate:self];
        [UALogger log:@"AsyncSocket new"];
    }
    if ([socket isConnected] == NO) {
        @synchronized(self) {
            [socket connectToHost:HTTPURL onPort:HTTPURLPort error:nil];
        }
        return NO;
    }
    return YES;
}

- (void)beginSendData
{
    if (currentReuqestTag == 0) {
        @synchronized(self) {
            long requestTag = (long)[[[self.requestTags allKeys] firstObject] longLongValue];
            //得到请求data
            NSData *requestData = [self getWriteDataWithRequestTag:requestTag];
            if (requestData == nil) {
                [UALogger log:@"beginSendData 生成 requestData 失败"];
                return;
            }
            [socket logOnDealloc];
            currentReuqestTag = requestTag;
            [socket readDataWithTimeout:RequestTimeoutInterval tag:requestTag];
            [socket writeData:requestData withTimeout:RequestTimeoutInterval tag:requestTag];
        }
    }
}

- (NSData *)getWriteDataWithRequestTag:(long)requestTag
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970]*1000;
    
    Byte byte[23];
    
    NSMutableDictionary *bodyDic = [[self.requestTags objectForKey:[@(requestTag) stringValue]] mutableCopy];
    if (bodyDic == nil) {
        [UALogger log:@"getWriteDataWithRequestTag 获取 bodyDic 失败"];
        return nil;
    }
    NSString *methodPort = [bodyDic objectForKey:kSocketRequestMethodPort];
    if (methodPort == nil || [methodPort integerValue] < 0) {
        [UALogger log:@"getWriteDataWithRequestTag methodPort 不合法"];
        return nil;
    }
    //移除请求端口
    [bodyDic removeObjectForKey:kSocketRequestMethodPort];
    //移除本地保存字段，如果有
    [bodyDic removeObjectForKey:kResponseModel_LocalSaveId_Sign];
    
    NSString *bodyString = nil;
    //如果没请求参数，则设置为空的请求体
    if ([bodyDic count] == 0) {
        bodyString = @"";
    }
    else {
        //用unicode编码，对中文转换
        bodyString = [bodyDic JSONStringWithOptions:JKSerializeOptionEscapeUnicode error:nil];
        //end
    }
    //end
    
    //长度
    NSInteger allL = 23 + bodyString.length;
    byte[0] =  ((allL>>24) & 0xFF);
    byte[1] =  ((allL>>16) & 0xFF);
    byte[2] =  ((allL>>8) & 0xFF);
    byte[3] =  (allL & 0xFF);
    
    //messageType 请求端口
    byte[4] =  (Byte)[methodPort integerValue];
    
    //clienType 客户端类型
    byte[5] =  (Byte)1;
    
    //clientVersion 客户端版本
    byte[6] =  (Byte)APPClientVersion;
    
    //secssionId， 会话ID，默认为登录过的手机号
    long long secssionId = self.secssionId?[self.secssionId longLongValue]:0;
    byte[7] =  (Byte)(secssionId >> 56);
    byte[8] =  (Byte)(secssionId >> 48);
    byte[9] =  (Byte)(secssionId >> 40);
    byte[10] =  (Byte)(secssionId >> 32);
    byte[11] =  (Byte)(secssionId >> 24);
    byte[12] =  (Byte)(secssionId >> 16);
    byte[13] =  (Byte)(secssionId >> 8);
    byte[14] =  (Byte)(secssionId >> 0);
    
    //时间槽，精确到毫秒
    byte[15] =  (Byte)(time >> 56);
    byte[16] =  (Byte)(time >> 48);
    byte[17] =  (Byte)(time >> 40);
    byte[18] =  (Byte)(time >> 32);
    byte[19] =  (Byte)(time >> 24);
    byte[20] =  (Byte)(time >> 16);
    byte[21] =  (Byte)(time >> 8);
    byte[22] =  (Byte)(time >> 0);
    
    //拼接请求data
    NSMutableData *data = [NSMutableData dataWithBytes:byte length:sizeof(byte)];
    [data appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [UALogger log:@"%@号接口请求---%@",methodPort,bodyString];
    return data;
}

- (NSString *)getResponseObjectWithResponseData:(NSData *)responseData
                             requestTag:(long)requestTag
{
    if (responseData == nil || [responseData length] <= 23) {
        return nil;
    }
    NSInteger lengthT = [responseData length] - 23;
    Byte bytenew[lengthT];
    [responseData getBytes:bytenew range:NSMakeRange(23, [responseData length] - 23)];
    NSString *string = [[NSString alloc] initWithBytes:bytenew length:lengthT encoding:NSUTF8StringEncoding];
    return string;
}

#pragma mark -
#pragma mark AsyncSocket Methods

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
#ifdef DEBUG
    NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
#endif
    //回调错误结果
    void (^resultBlock)(id responseObject, NSError *error) = [self.responseTags objectForKey:[@(connectTag?:currentReuqestTag) stringValue]];
    //异步回调结果
    if (resultBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            resultBlock(nil, err);
            //结果执行完了再移除
            [self.responseTags removeObjectForKey:[@(connectTag?:currentReuqestTag) stringValue]];
            //移除当前请求的tag
            [self.requestTags removeObjectForKey:[@(connectTag?:currentReuqestTag) stringValue]];
            currentReuqestTag = 0;
            //end
        });
    }
    //end
    
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    
    [UALogger log:@"Disconnected."];
//    [socket setDelegate:nil];
//    socket = nil;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    [UALogger log:@"onSocketWillConnect:"];
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [UALogger log:@"Connected To %@:%i.", host, port];
    //isConnecting = NO;
    if ([self.requestTags count] > 0) {
        [self beginSendData];
    }
    else {
        @synchronized(self) {
            [socket disconnect];
        }
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    /**
     * Convert data to a string for logging.
     *
     * http://stackoverflow.com/questions/550405/convert-nsdata-bytes-to-nsstring
     */
    @synchronized(self) {
        //判断在缓存data里是否有数据
        NSMutableData *tagLengthData = nil;
        if ([[self.responseData allKeys] containsObject:[@(tag) stringValue]]) {
            //这时候 数组里存的就是完整的数据了
            tagLengthData = [self.responseData objectForKey:[@(tag) stringValue]];
        }
        else {
            tagLengthData = [NSMutableData dataWithData:data];
        }
        //获取要读取的总长度
        Byte bytes[4];
        [tagLengthData getBytes:bytes length:4];
        NSInteger tagLength = 0;
        for (NSInteger i = 0; i < 4; i++) {
            NSInteger shift = (4 - 1 - i) * 8;
            tagLength += (bytes[i] & 0x000000FF) << shift;
        }
        //判断是否读取完
        if (tagLength > [tagLengthData length]) {
            [self.responseData setValue:tagLengthData forKey:[@(tag) stringValue]];
            
            [socket readDataWithTimeout:RequestTimeoutInterval buffer:tagLengthData bufferOffset:[tagLengthData length] maxLength:0 tag:tag];
            return;
        }
        
        //得到结果
        NSString *responseString = [self getResponseObjectWithResponseData:tagLengthData requestTag:tag];
        //移除缓存data
        if ([[self.responseData allKeys] containsObject:[@(tag) stringValue]]) {
            [self.responseData removeObjectForKey:[@(tag) stringValue]];
        }
        //end
        [UALogger log:@"%@号接口---收到数据---%@---长度---%d",[self.requestTags[[@(tag) stringValue]] objectForKey:kSocketRequestMethodPort],responseString,tagLengthData.length];
        
        void (^resultBlock)(id responseObject, NSError *error) = [self.responseTags objectForKey:[@(tag) stringValue]];
        NSError *error = nil;
        id responseObject = nil;
        @try {
            responseObject = [self.responseSerializer responseObjectForRequestParams:self.requestTags[[@(tag) stringValue]] dataString:responseString error:&error];
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(nil, error);
                
                //需要缓存的接口，保存数据到本地
                NSDictionary *requestDic = self.requestTags[[@(tag) stringValue]];
                if ([[requestDic allKeys] containsObject:kResponseModel_LocalSaveId_Sign]) {
                    [self saveResponseDataWithSaveId:requestDic[kResponseModel_LocalSaveId_Sign] responseString:responseString];
                }
                //end
                
                //移除当前请求的tag
                currentReuqestTag = 0;
                [self.requestTags removeObjectForKey:[@(tag) stringValue]];
                [self.responseTags removeObjectForKey:[@(tag) stringValue]];
                //end
                
                if ([self.requestTags count] > 0) {
                    [self beginSendData];
                }
                else {
                    [socket disconnect];
                }
                
            });
        }
        //异步回调结果
        if (resultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(responseObject, error);
                
                //需要缓存的接口，保存数据到本地
                NSDictionary *requestDic = self.requestTags[[@(tag) stringValue]];
                if ([[requestDic allKeys] containsObject:kResponseModel_LocalSaveId_Sign]) {
                    [self saveResponseDataWithSaveId:requestDic[kResponseModel_LocalSaveId_Sign] responseString:responseString];
                }
                //end
                
                //移除当前请求的tag
                currentReuqestTag = 0;
                [self.requestTags removeObjectForKey:[@(tag) stringValue]];
                [self.responseTags removeObjectForKey:[@(tag) stringValue]];
                //end
                
                if ([self.requestTags count] > 0) {
                    [self beginSendData];
                }
                else {
                    [socket disconnect];
                }
                
            });
        }
        //end
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    [UALogger log:@"onSocket:didReadPartialDataOfLength:%i tag:%li", partialLength, tag];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [UALogger log:@"onSocket:didWriteDataWithTag:%li", tag];
}

#pragma mark - 网络数据本地保存 与 读取

- (NSString *)dataParseLocalSavePath
{
    NSString *fileFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileSaveFolder = [fileFolder stringByAppendingString:@"/ParseLocalData"];
    
    BOOL isDir = FALSE;
    BOOL isDirExist = [NSFileManager.defaultManager fileExistsAtPath:fileSaveFolder isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [NSFileManager.defaultManager createDirectoryAtPath:fileSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir) {
            [UALogger log:@"CCParseToObjectToDatabase---dataParseLocalSavePath---Create Database Directory Failed."];
        }
    }
    return fileSaveFolder;
}

/**
 *  保存到本地
 */
- (void) saveResponseDataWithSaveId:(NSString *)saveId responseString:(NSString *)responseString
{
    if (saveId == nil || responseString == nil) {
        return;
    }
    
    //本地文件形式缓存
    [responseString writeToFile:[[self dataParseLocalSavePath] stringByAppendingPathComponent:[saveId stringFromMD5]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

/**
 *  读取本地缓存数据
 */
- (NSString *) readSavedResponseDataWithSaveId:(NSString *)saveId
{
    if (saveId == nil) {
        return nil;
    }
    //本地文件形式
    NSString *filePath = [[self dataParseLocalSavePath] stringByAppendingPathComponent:[saveId stringFromMD5]];
    BOOL isDic = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDic]) {
        return [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }
    else {
        return nil;
    }
    //end
}


#pragma mark - getters and setters

- (NSMutableDictionary *)requestTags
{
    if (_requestTags == nil) {
        _requestTags = [NSMutableDictionary dictionary];
    }
    return _requestTags;
}

- (NSMutableDictionary *)responseTags
{
    if (_responseTags == nil) {
        _responseTags = [NSMutableDictionary dictionary];
    }
    return _responseTags;
}

- (NSMutableDictionary *)responseData
{
    if (_responseData == nil) {
        _responseData = [NSMutableDictionary dictionary];
    }
    return _responseData;
}

@end
