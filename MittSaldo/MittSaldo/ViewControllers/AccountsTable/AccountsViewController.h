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
#import "AccountsTableViewController.h"

@interface AccountsViewController : UIViewController <AccountsTableViewControllerDelegate>

+ (AccountsViewController *)controller;
- (void)updateServicesWhenVisible;

@property (nonatomic, retain) IBOutlet UILabel *noBanksInfoLabel;
@property (nonatomic, retain) IBOutlet UIImageView *noBanksInfoArrow;

@end
