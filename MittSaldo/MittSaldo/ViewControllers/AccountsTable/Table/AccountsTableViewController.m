//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AccountsTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AccountInfoTableViewCell.h"
#import "AccountTotalsTableViewCell.h"
#import "MittSaldoSettings.h"
#import "MSBankAccount.h"
#import "MSConfiguredBank+Helper.h"
#import "AccountDetailsView.h"
#import "AccountUpdater.h"
#import "AccountsTableHeaderView.h"
#import "NSDate+Helper.h"
#import "UIAlertView+MSHelper.h"

@interface AccountsTableViewController()
- (void)loadAccounts;
- (void)reloadTableView;

@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@property (nonatomic, retain) NSMutableArray *tableSections;
@property (nonatomic, retain) NSDictionary *tableRows;
@property (nonatomic, retain) AccountUpdater *accountUpdater;
@property (nonatomic, retain) UILabel *updateStatusLabel;
@end

@implementation AccountsTableViewController

- (void)dealloc 
{
    [_tableRows release];
	[_tableSections release];
    [_accountUpdater release];
    [_numberFormatter release];
    
	// Outlets
	[_tableView release];
	
    [super dealloc];
}

+ (AccountsTableViewController *)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	   
    // set options.
	NSNumberFormatter *nrFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[nrFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[nrFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[nrFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
    self.numberFormatter = nrFormatter;
    
    self.accountUpdater = [[[AccountUpdater alloc] init] autorelease];
    self.accountUpdater.successBlock = ^(MSConfiguredBank *bank) {
        [self updateDidSucceedForBank:bank];
    };
    self.accountUpdater.failureBlock = ^(MSConfiguredBank *bank, NSError *error, NSString *message) {
        [self updateDidFailForBank:bank error:error message:message];
    };
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self enqueAllBanksForUpdate];
    }];
    
    self.updateStatusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 36, self.tableView.pullToRefreshView.contentView.bounds.size.width, 20)] autorelease];
    self.updateStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.updateStatusLabel.font = [UIFont systemFontOfSize:12];
    self.updateStatusLabel.backgroundColor = [UIColor clearColor];
    [self.tableView.pullToRefreshView.contentView addSubview:self.updateStatusLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
	// Load account data
	[self reloadTableView];
    
    // Check if a bank was added
    NSArray *configuredBanks = [MittSaldoSettings configuredBanks];
    for (MSConfiguredBank *bank in configuredBanks) {
        if (![self.tableSections containsObject:bank]) {
            [self enqueueBankForUpdate:bank];
            
            // This will pull the view down without triggering an actual update
            [self.tableView.pullToRefreshView startAnimating];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Update logic

- (void)updateHeaderStatusText
{
    NSMutableString *beingUpdated = [NSMutableString string];
    
    if (self.accountUpdater) {
        for (MSConfiguredBank *bank in self.accountUpdater.banksBeingUpdated) {
            if ([beingUpdated length] > 0)
                [beingUpdated appendString:@", "];
            
            [beingUpdated appendString:bank.name];
        }
    }
    
    self.updateStatusLabel.text = beingUpdated; 
}

- (void)enqueAllBanksForUpdate
{
	NSArray *configuredBanks = [MittSaldoSettings configuredBanks];
    
	if ([configuredBanks count] > 0) {
        for (MSConfiguredBank *bank in configuredBanks) {
            [self.accountUpdater enqueueBankForUpdate:bank];
        }
        
        [self updateHeaderStatusText];
        [self reloadTableView];
	}
}

- (void)enqueueBankForUpdate:(MSConfiguredBank *)bank
{
    [self.accountUpdater enqueueBankForUpdate:bank];
    [self updateHeaderStatusText];
    [self.tableView reloadData];
}

- (void)updateDidSucceedForBank:(MSConfiguredBank *)bank
{
    [self reloadTableView];
    if (!self.accountUpdater.isUpdating) {
        [self.tableView.pullToRefreshView stopAnimating];
    }
    [self updateHeaderStatusText];
}

- (void)updateDidFailForBank:(MSConfiguredBank *)failedBank error:(NSError *)error message:(NSString *)message
{
    if (!self.accountUpdater.isUpdating) {
        [self.tableView.pullToRefreshView stopAnimating];
    }
    
    [UIAlertView showUpdateDidFailAlertForBank:failedBank error:error message:message errorReportingDelegate:self];
    
    [self updateHeaderStatusText];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (void)loadAccounts
{
    NSManagedObjectContext *moc = [NSManagedObjectContext sharedContext];
	
	// Grab all hidden accounts
	int nrOfHiddenAccounts = [[moc searchObjectsInContext:@"MSBankAccount" 
														   predicate:[NSPredicate predicateWithFormat:@"(displayAccount == 0)"]  
															 sortKey:@"bankIdentifier,accountid" 
													   sortAscending:YES] count];
	
	
	// If there are hidden accounts, show the button to toggle hidden accounts
	if (nrOfHiddenAccounts > 0 && self.parentViewController.navigationItem.rightBarButtonItem == nil) {
		UIBarButtonItem *viewHiddenAccountsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eye.png"] 
																					 style:UIBarButtonItemStyleBordered 
																					target:self 
																					action:@selector(showHiddenAccounts:)];
		
        self.parentViewController.navigationItem.rightBarButtonItem = viewHiddenAccountsButton;
		[viewHiddenAccountsButton release];
	}
	// Remove the toggle button if it is visible and there are no hidden accounts.
	else if (nrOfHiddenAccounts == 0 && self.navigationItem.rightBarButtonItem != nil) {
		self.parentViewController.navigationItem.rightBarButtonItem = nil;
	}
	    
	NSMutableArray* mutableFetchResults = [moc searchObjectsInContext:@"MSConfiguredBank"
																	   predicate:nil  
																		 sortKey:@"name" 
																   sortAscending:YES];
	
	self.tableSections = [NSMutableArray array];
	self.tableRows = [NSMutableDictionary dictionary];
    totalAccountsAmount = totalAvailableAmount = 0;
    
	for (int i = 0, resultCount = [mutableFetchResults count]; i < resultCount; i++) {
        MSConfiguredBank *bank = [mutableFetchResults objectAtIndex:i]; 

        if ([bank.accounts count] > 0) {
            NSMutableArray *accounts = [NSMutableArray array];
            for (MSBankAccount *account in bank.accounts) {
                if ([account.displayAccount boolValue] || showHiddenAccounts) {
                    totalAccountsAmount += [account.amount floatValue];
                    totalAvailableAmount += account.availableAmount ? [account.availableAmount floatValue] : [account.amount floatValue];
                    
                    [accounts addObject:account];                        
                }
            }
            
            if ([accounts count] > 0) {
                NSArray *sortedAccounts = [accounts sortedArrayUsingComparator:^NSComparisonResult(MSBankAccount *obj1, MSBankAccount *obj2) {
                    return [obj1.accountid compare:obj2.accountid];
                }];
                
                [self.tableSections addObject:bank];
                [self.tableRows setValue:sortedAccounts forKey:bank.guid];
            }
        }
	}
}

- (void)reloadTableView
{
	[self loadAccounts];
	[self.tableView reloadData];
    
    if (self.delegate) {
        [self.delegate didReloadTableView];
    }
}

- (MSBankAccount *)bankAccountForIndexPath:(NSIndexPath *)indexPath
{
    MSConfiguredBank *bank = [self.tableSections objectAtIndex:indexPath.section];
    MSBankAccount *account = [[self.tableRows objectForKey:bank.guid] objectAtIndex:indexPath.row];

    return account;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	int sections = [self.tableSections count];
	
	if (sections > 0) {
		// Add section for totals
		sections++;
	}
	else {
        // One section if we have no content
        sections = 1;
    }
    
	return sections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int sectionCount = [self.tableSections count];
    
    if (sectionCount == 0) {
        return 0;
    }
    
    if (section < sectionCount) {
        return 40;        
    }

    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int sectionCount = [self.tableSections count];
    
    if (sectionCount == 0)
        return nil;
    
    AccountsTableHeaderView *header = [AccountsTableHeaderView view];
    
    if (section < sectionCount) {
        MSConfiguredBank *bank = [self.tableSections objectAtIndex:section];
        header.title = bank.name;
        header.section = section;
        [header.updateButton addTarget:self action:@selector(updateBankAction:) forControlEvents:UIControlEventTouchUpInside];
        
        MSBankAccount *account = [[self.tableRows valueForKey:bank.guid] lastObject];
        header.updatedDate = [NSString stringWithFormat:@"Uppdaterad: %@", [NSDate stringForDisplayFromDate:account.updatedDate alwaysDisplayTime:YES]];
        
        if (self.accountUpdater && self.accountUpdater.isUpdating && [self.accountUpdater isUpdatingBankWithGuid:bank.guid]) {
            [header showUpdateAnimation];
        }
        else {
            [header hideUpdateAnimation];
        }
    }
    else {
        header.title = NSLocalizedString(@"TotalBalance", nil);
    }

    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.tableSections count]) {
        return 64;
    }
	else {
		MSBankAccount *account = [self bankAccountForIndexPath:indexPath];
        
		if (account.availableAmount) {
			return 64;
		}
	}

	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // return 2 rows if we have no actual content 
    if ([self.tableSections count] == 0) {
        return 2;
    }
    
	int rowsInSection = 0;
	
	if (section < [self.tableSections count]) {
        MSConfiguredBank *bank = [self.tableSections objectAtIndex:section];
		rowsInSection = [[self.tableRows objectForKey:bank.guid] count];
	}
	else {
		// This is for the totals section. We just have one row
		rowsInSection = 1;
	}

	return rowsInSection;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = nil;
    
    int tableSectionCount = [self.tableSections count];
    if (tableSectionCount == 0) {
		static NSString *helpCell = @"HelpCell";
        cell = [sender dequeueReusableCellWithIdentifier:helpCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:helpCell] autorelease];
        }
        
        
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Dra ner för att uppdatera";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        else {
            cell.textLabel.text = @"";
        }
    }
	else if (indexPath.section > tableSectionCount-1) {
        
		static NSString *totalsCellIdentifier = @"TotalsCell";
		AccountTotalsTableViewCell *totalsCell = [sender dequeueReusableCellWithIdentifier:totalsCellIdentifier];
		
		if (totalsCell == nil) {
			totalsCell = [[[AccountTotalsTableViewCell alloc] initWithReuseIdentifier:totalsCellIdentifier] autorelease];
			totalsCell.contentView.backgroundColor = [UIColor whiteColor];
			totalsCell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		totalsCell.accountsAmount = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAccountsAmount]];
        totalsCell.accountsAvailableAmount = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:totalAvailableAmount]];
        
        cell = totalsCell;
	}
	else {
        
        MSBankAccount *bankAccount = [self bankAccountForIndexPath:indexPath];
		
        BOOL availableAmount = bankAccount.availableAmount != nil;
		NSString *CellIdentifier = availableAmount ? @"AvailableCell" : @"Cell";
		
		cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[AccountInfoTableViewCell alloc] initWithReuseIdentifier:CellIdentifier showAvailableAmount:availableAmount] autorelease];
			
			cell.contentView.backgroundColor = [UIColor whiteColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		AccountInfoTableViewCell *accountCell = (AccountInfoTableViewCell *)cell;
		accountCell.accountTitle.text = bankAccount.displayName ? bankAccount.displayName : bankAccount.accountName;
		accountCell.accountAmount.text = [NSString stringWithFormat:@"%@: %@.", NSLocalizedString(@"AccountBalance", nil), 
										  [self.numberFormatter stringFromNumber:bankAccount.amount]];
		
		if (availableAmount) {
			accountCell.accountAvailableAmount.text = [NSString stringWithFormat:@"%@: %@.", NSLocalizedString(@"AvailableAccountBalance", nil), 
													   [self.numberFormatter stringFromNumber:bankAccount.availableAmount]];
		}
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{  
	if (indexPath.section < [self.tableSections count]) {
		MSBankAccount *selectedAccount = [self bankAccountForIndexPath:indexPath];
		[self.navigationController pushViewController:[AccountDetailsView accountDetailsViewForAccount:selectedAccount] animated:YES];
	}
}

#pragma mark - Actions

- (IBAction)updateBankAction:(id)sender
{
    if ([((UIView *)sender).superview isKindOfClass:[AccountsTableHeaderView class]]) {
        AccountsTableHeaderView *header = (AccountsTableHeaderView *)((UIView *)sender).superview;
        MSConfiguredBank *bank = [self.tableSections objectAtIndex:header.section];
        [self enqueueBankForUpdate:bank];
    }
}

- (IBAction)showHiddenAccounts:(id)sender
{
	showHiddenAccounts = !showHiddenAccounts;
	UIBarButtonItem *senderBtn = sender;
	senderBtn.image = [UIImage imageNamed:showHiddenAccounts ? @"eye-black.png" : @"eye.png"];
    
	[self reloadTableView];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kErrorReportingAlertTag) {
        if (buttonIndex == 1) {
            // Navigate to error reporting.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MS-NavigateTo" object:self userInfo:[NSDictionary dictionaryWithObject:@"errorReporting" forKey:@"view"]];
        }
    }
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AccountsTableView";
}

@end

