//
//  DKCompositeIndexBottomView.h
//  DataKit
//
//  Created by wangyangyang on 15/12/2.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DKCompositeIndexBottomData;
@interface DKCompositeIndexBottomView : UIView

- (instancetype)initWithWidth:(CGFloat)width;

- (void)updateWithData:(DKCompositeIndexBottomData *)data isLeft:(BOOL)isLeft;

@end
