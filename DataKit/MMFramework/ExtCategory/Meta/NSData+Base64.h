//
//  NSData+Base64.h
//  DES-Test
//
//  Created by mmc on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)

- (NSString *)base64Encoding;
+ (id)dataWithBase64EncodedString:(NSString *)string;

@end
