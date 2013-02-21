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

#import "SkanetrafikenDetailsViewController.h"
#import "BSPullToRefresh.h"
#import "MSLSkanetrafikenServiceProxy.h"
#import "AccountUpdater.h"
#import "MSConfiguredBank+Helper.h"
#import "UIAlertView+MSHelper.h"
#import "MSBankAccount.h"

@interface SkanetrafikenDetailsViewController ()
@property (nonatomic, retain) NSArray *accounts;
@end

@implementation SkanetrafikenDetailsViewController

- (void)dealloc
{
    [_accounts release];
    [_detailsTableView release];
    [super dealloc];
}

+ (SkanetrafikenDetailsViewController *)controllerWithCard:(MSConfiguredBank *)card
{
    SkanetrafikenDetailsViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
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
        MSLSkanetrafikenServiceProxy *loginProxy = [MSLSkanetrafikenServiceProxy proxyWithUsername:self.configuredCard.ssn andPassword:self.configuredCard.password];
        
        [loginProxy performLoginWithSuccessBlock:^{
            [loginProxy fetchAccountBalance:^(NSArray *accounts) {
                // Persist the update
                [AccountUpdater persistAccountBalance:self.configuredCard accounts:accounts];
                
                NSMutableArray *parsedAccounts = [NSMutableArray array];

                for (NSDictionary *cardDict in loginProxy.accountDetailDictionaries) {
                    NSMutableArray *cardMetaData = [NSMutableArray array];
                    
                    NSString *title = @"Kortnummer";
                    NSString *value = [cardDict valueForKey:@"accountid"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Status";
                    value = [cardDict valueForKey:@"status"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Zoner";
                    value = [cardDict valueForKey:@"validzones"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Giltig period";
                    value = [cardDict valueForKey:@"validPeriod"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Reskassa";
                    value = [cardDict valueForKey:@"balance"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];

                    NSMutableDictionary *cardInfo = [NSMutableDictionary dictionary];
                    [cardInfo setValue:[cardDict valueForKey:@"name"] forKey:@"name"];
                    [cardInfo setValue:cardMetaData forKey:@"metadata"];
                    
                    [parsedAccounts addObject:cardInfo];
                }
                
                self.accounts = parsedAccounts;
                [self.detailsTableView reloadData];
                [self.detailsTableView.pullToRefreshView stopAnimating];
                
            } failure:failureBlock];
            
        } failure:failureBlock];
    }];
}

- (void)updateServiceInformation
{
    
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
    return [self.accounts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CardDetailsTableHeaderView *header = [CardDetailsTableHeaderView view];
    
    NSDictionary *accountDict = [self.accounts objectAtIndex:section];
    header.title = [accountDict valueForKey:@"name"];
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *accountDict = [self.accounts objectAtIndex:section];
    return [[accountDict valueForKey:@"metadata"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSDictionary *account = [self.accounts objectAtIndex:indexPath.section];
    NSDictionary *metadata = [[account valueForKey:@"metadata"] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [metadata valueForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [metadata valueForKey:@"value"]];
    
    
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
    return @"SkanetrafikenDetailsView";
}
@end
