//
//  UIAlertView+Helper.h
//  MittSaldo
//
//  Created by  on 3/8/12.
//  Copyright (c) 2012 Björn Sållarp. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const int kErrorAlertViewTag;

@interface UIAlertView (Helper)

+ (void)showErrorAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;

@end
