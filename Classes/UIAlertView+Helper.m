//
//  UIAlertView+Helper.m
//  MittSaldo
//
//  Created by  on 3/8/12.
//  Copyright (c) 2012 Björn Sållarp. All rights reserved.
//

#import "UIAlertView+Helper.h"

const int kErrorAlertViewTag = 999;

@implementation UIAlertView (Helper)

+ (void)showErrorAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:NSLocalizedString(@"ErrorReportAlertViewButton", nil), nil];
    alert.tag = kErrorAlertViewTag;
    [alert show];
    [alert release];
}

@end
