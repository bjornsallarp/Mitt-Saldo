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

#import "ICACArdDetailsViewController.h"
#import "MSLICACardServiceProxy.h"
#import "AccountUpdater.h"
#import "MSConfiguredBank+Helper.h"
#import "BSPullToRefresh.h"
#import "MSLParsedAccount.h"
#import "UIAlertView+MSHelper.h"

@interface ICACardDetailsViewController ()
@property (nonatomic, retain) NSArray *detailsArray;
@end

@implementation ICACardDetailsViewController

- (void)dealloc
{   
    [_detailsArray release];
    [_detailsTableView release];
    [super dealloc];
}

+ (ICACardDetailsViewController *)controllerWithCard:(MSConfiguredBank *)card
{
    ICACardDetailsViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
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
        MSLICACardServiceProxy *loginProxy = [MSLICACardServiceProxy proxyWithUsername:self.configuredCard.ssn andPassword:self.configuredCard.password];
        
        [loginProxy performLoginWithSuccessBlock:^{
            [loginProxy fetchAccountBalance:^(NSArray *accounts) {
                
                NSDictionary *clientAccountData = [loginProxy.balanceJsonResponse valueForKey:@"ClientAccountData"];
                NSDictionary *customerBonusData = [loginProxy.balanceJsonResponse valueForKey:@"CustomerBonusData"];
                NSMutableArray *detailsArray = [NSMutableArray array];
                NSString *value = nil;
                
                if (clientAccountData != (id)[NSNull null]) {
                    value = [[clientAccountData valueForKey:@"AccountNumber"] stringValue];
                    [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"KONTONUMMER", @"caption", nil]];
                    
                    value = [NSString stringWithFormat:@"%@ kr", [clientAccountData valueForKey:@"Available"]];
                    [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Disponibelt", @"caption", nil]];
                    
                    value = [NSString stringWithFormat:@"%@ kr", [clientAccountData valueForKey:@"Balance"]];
                    [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Saldo", @"caption", nil]];
                    
                    value = [NSString stringWithFormat:@"%@ kr", [clientAccountData valueForKey:@"CreditLimit"]];
                    [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Beviljad kredit", @"caption", nil]];
                    
                    value = [NSString stringWithFormat:@"%@ poäng", [customerBonusData valueForKey:@"CurrentAmountOfPointsOfAccount"]];
                    [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Aktuellt poängsaldo", @"caption", nil]];
                }
                
                value = [NSString stringWithFormat:@"%@ kr", [customerBonusData valueForKey:@"AmountOfSwedishCrownsToNextBonusCheck"]];
                [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Kvar till nästa bonuscheck", @"caption", nil]];
                
                value = [NSString stringWithFormat:@"%@ kr", [customerBonusData valueForKey:@"PurchasesMadeOnIcaCurrentYear"]];
                [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Årets totala inköp på ICA", @"caption", nil]];
                
                value = [NSString stringWithFormat:@"%@ kr", [customerBonusData valueForKey:@"RecievedBonusOfCurrentYear"]];
                [detailsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:value, @"value", @"Erhållen bonus i år", @"caption", nil]];
                
                [AccountUpdater persistAccountBalance:self.configuredCard accounts:accounts];
                
                self.detailsArray = detailsArray;
                [self.detailsTableView reloadData];
                [self.detailsTableView.pullToRefreshView stopAnimating];
                
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return MAX(1, [self.detailsArray count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    static NSString *detailCell = @"DetailCell";
    cell = [tableView dequeueReusableCellWithIdentifier:detailCell];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:detailCell] autorelease];
    }
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    if (self.detailsArray) {
        NSDictionary *dict = [self.detailsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict valueForKey:@"caption"];
        cell.detailTextLabel.text = [dict valueForKey:@"value"];
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
    return @"ICACardDetailsView";
}

@end
