//
//  MMCellProtocol.h
//  XinHuaPublish
//
//  Created by wangyangyang on 15/4/5.
//  Copyright (c) 2015年 wang yangyang. All rights reserved.
//

#ifndef XinHuaPublish_MMCellProtocol_h
#define XinHuaPublish_MMCellProtocol_h

@protocol MMCellProtocol <NSObject>

@required

- (void)setContentWithObject:(id)object AtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)setCellDelegate:(id) object;

/**
 *  cell从屏幕上消失的时候调用
 */
- (void)setCellDidEndDisplaying;

@end

#endif
