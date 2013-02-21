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

#import "CoopCardDetailsViewController.h"
#import "BSPullToRefresh.h"
#import "MSLCoopCardServiceProxy.h"
#import "AccountUpdater.h"
#import "MSConfiguredBank+Helper.h"
#import "UIAlertView+MSHelper.h"
#import "MSBankAccount.h"

@interface CoopCardDetailsViewController ()
@property (nonatomic, retain) NSArray *accounts;
@property (nonatomic, retain) NSArray *refundSummary;
@end

@implementation CoopCardDetailsViewController

- (void)dealloc
{
    [_refundSummary release];
    [_accounts release];
    [_detailsTableView release];
    [super dealloc];
}

+ (CoopCardDetailsViewController *)controllerWithCard:(MSConfiguredBank *)card
{
    CoopCardDetailsViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
    controller.configuredCard = card;
    
    return [controller autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MSLServiceFailureBlock failureBlock = ^(NSError *error, NSString *errorMessage) {
        [self.detailsTableView.pullToRefreshView stopAnimating];
        [UIAlertView showUpdateDidFailAlertForBank:self.configuredCard error:error message:errorMessage errorReportingDelegate:self];
    };
    
    [self.detailsTableView addPullToRefreshWithActionHandler:^{
        MSLCoopCardServiceProxy *loginProxy = [MSLCoopCardServiceProxy proxyWithUsername:self.configuredCard.ssn andPassword:self.configuredCard.password];
        
        [loginProxy performLoginWithSuccessBlock:^{
            [loginProxy fetchAccountBalance:^(NSArray *accounts) {
                self.accounts = accounts;
                
                // Persist the update
                [AccountUpdater persistAccountBalance:self.configuredCard accounts:accounts];
                [self.detailsTableView reloadData];
                
                [loginProxy fetchRefundSummary:^(NSDictionary *response) {
                    NSMutableArray *summary = [NSMutableArray array];
                    
                    NSString *title = [NSString stringWithFormat:@"Återbäring %@", [response objectForKey:@"MonthName"]];
                    NSString *value = [NSString stringWithFormat:@"%.1f%%", [[response valueForKey:@"ProfileRate"] doubleValue] * 100];
                    [summary addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Kvar till nästa nivå";
                    value = [NSString stringWithFormat:@"%.2f kr", [[response valueForKey:@"ProfileNextRateDistance"] doubleValue]];
                    [summary addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = [NSString stringWithFormat:@"Insamling %@", [response objectForKey:@"MonthName"]];
                    value = [NSString stringWithFormat:@"%.2f kr", [[response valueForKey:@"TotalRefund"] doubleValue]];
                    [summary addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Total insamling";
                    value = [NSString stringWithFormat:@"%.2f kr", [[response valueForKey:@"PeriodRefund"] doubleValue]];
                    [summary addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    self.refundSummary = summary;
                    
                    [self.detailsTableView reloadData];
                    [self.detailsTableView.pullToRefreshView stopAnimating];
                    
                } failure:failureBlock];
                
            } failure:failureBlock];
            
        } failure:failureBlock];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Start update
    [self.detailsTableView.pullToRefreshView triggerUpdate];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CardDetailsTableHeaderView *header = [CardDetailsTableHeaderView view];
    header.title = section == 0 ? @"Saldo" : @"Återbäring";
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.accounts count];
    }
    else {
        return [self.refundSummary count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
		static NSString *balanceCell = @"BalanceCell";
        cell = [tableView dequeueReusableCellWithIdentifier:balanceCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:balanceCell] autorelease];
        }
        
        MSBankAccount *account = [self.accounts objectAtIndex:indexPath.row];
        cell.textLabel.text = account.accountName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f kr", [account.amount doubleValue]];
    }
    else {
		static NSString *transactionCell = @"TransactionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:transactionCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:transactionCell] autorelease];
        }
        
        if ([self.refundSummary count] > 0) {
            NSDictionary *item = [self.refundSummary objectAtIndex:indexPath.row];
            cell.textLabel.text = [item valueForKey:@"title"];
            cell.detailTextLabel.text = [item valueForKey:@"value"];
        }
    }
    
    return cell;
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
    return @"CoopCardDetailsView";
}

@end
