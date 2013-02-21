//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//

#import <UIKit/UIKit.h>
#import "BSGradientView.h"

@interface AccountsTableHeaderView : BSGradientView

+ (AccountsTableHeaderView *)view;

@property (nonatomic, retain) NSString *updatedDate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIButton *updateButton;
@property (nonatomic, assign) int section;

- (void)showUpdateAnimation;
- (void)hideUpdateAnimation;

@end
