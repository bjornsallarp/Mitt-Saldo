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

@class MSConfiguredBank;

@interface CardDetailsBaseViewController : UIViewController
+ (CardDetailsBaseViewController *)controllerForCard:(MSConfiguredBank *)card;
@property (nonatomic, retain) IBOutlet MSConfiguredBank *configuredCard;
@end

@interface CardDetailsTableHeaderView : BSGradientView
+ (CardDetailsTableHeaderView *)view;
@property (nonatomic, retain) NSString *title;
@end
