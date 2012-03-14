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
#import <QuartzCore/QuartzCore.h>
#import "BankAccount.h"
#import "CoreDataHelper.h"
#import "AccountDetailsView.h"
#import "AccountUpdater.h"
#import "MittSaldoSettings.h"
#import "EGORefreshTableHeaderView.h"

@interface RootViewController : UIViewController <EGORefreshTableHeaderDelegate, AccountUpdaterDelegate, UIAlertViewDelegate> {
	UITableView *tableView;
	
    EGORefreshTableHeaderView *_refreshHeaderView;
	NSManagedObjectContext *managedObjectContext;
	NSMutableArray *tableSections;
	NSMutableDictionary *tableRows;
	NSMutableArray *banksToUpdate;
	float totalAccountsAmount;
	
	IBOutlet UIView  *updatingLabelBackgroundView;
	IBOutlet UILabel *updatingLabel;
	IBOutlet UILabel *noAccountInfoLabel;
	
	BOOL showHiddenAccounts;
}
-(void)loadAccounts;
-(void)removeAccountsForBank:(NSString*)bankIdentifier;
-(void)reloadTableView;

-(void)accountsUpdated:(id)sender;
-(void)accountsUpdatedError:(id)sender;

-(IBAction)refreshAccounts:(id)sender;

@property (nonatomic, retain) NSMutableArray *tableSections;
@property (nonatomic, retain) NSMutableDictionary *tableRows;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UILabel *updatingLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@end
