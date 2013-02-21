//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>
#import "BSPullToRefresh.h"

@protocol AccountsTableViewControllerDelegate <NSObject>
- (void)didReloadTableView;
@end

@interface AccountsTableViewController : UIViewController
{
    float totalAccountsAmount;
    float totalAvailableAmount;
	BOOL showHiddenAccounts;
}

+ (AccountsTableViewController *)controller;
- (void)enqueAllBanksForUpdate;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<AccountsTableViewControllerDelegate> delegate;

@end
