//
//  DKCaringCollectionViewCell.h
//  DataKit
//
//  Created by wangyangyang on 15/11/26.
//  Copyright © 2015年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DKCaringCollectionViewCellProtocol;
@interface DKCaringCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<DKCaringCollectionViewCellProtocol> c_delegate;

- (void)setContentWithObject:(id)object AtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DKCaringCollectionViewCellProtocol <NSObject>

- (void)remindButtonTaped:(NSIndexPath *)indexPath;

@end
