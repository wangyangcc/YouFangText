//
//  DKDataMultipleSelectionView.h
//  DataKit
//
//  Created by wangyangyang on 15/11/25.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDataMultipleSelectionContentWidth 150
#define kDataMultipleSelectionContentHeight 194

@interface DKDataMultipleSelectionView : UIView

@property (nonatomic, copy) NSString *tagSelection;

@property (copy) void (^onButtonTouchUpInside)(DKDataMultipleSelectionView *selectionView, NSString *buttonMark);

- (BOOL)isShow;

- (BOOL)show;

- (BOOL)hideWithCompletion:(void (^)(BOOL finished))completion;


@end
