//
//  MMCellObjectProtocol.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/5.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef XinHuaPublish_MMCellObjectProtocol_h
#define XinHuaPublish_MMCellObjectProtocol_h

@protocol MMCellObjectProtocol <NSObject>

@required

- (CGFloat)cellHeightForObject;

@optional

- (void)cellPushViewControllerWithTableData:(NSArray *)tableData
                                  indexPath:(NSIndexPath *)indexPath;

/**
 *  得到cell对应的id
 *
 *  @return id
 */
- (NSString *)getObjectId;

@end

#endif
