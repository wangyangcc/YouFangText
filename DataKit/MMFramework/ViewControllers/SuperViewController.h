//
//  SuperViewController.h
//  TestNav
//
//  Created by lcc on 13-12-12.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuperViewController : UIViewController

@property (weak) id s_delegate;

- (void) loadWithObject:(id) object;

- (void) setCenterVCWithString:(NSString *) VCString object:(id) object;

@end
