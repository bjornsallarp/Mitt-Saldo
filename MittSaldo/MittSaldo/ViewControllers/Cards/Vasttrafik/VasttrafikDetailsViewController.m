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

#import "VasttrafikDetailsViewController.h"
#import "BSPullToRefresh.h"
#import "MSLVasttrafikCardServiceProxy.h"
#import "AccountUpdater.h"
#import "MSConfiguredBank+Helper.h"
#import "UIAlertView+MSHelper.h"
#import "MSBankAccount.h"
#import "JSONKit.h"
#import "NSDate+Helper.h"

@interface VasttrafikDetailsViewController ()
@property (nonatomic, retain) NSArray *accounts;
@end

@implementation VasttrafikDetailsViewController

- (void)dealloc
{
    [_accounts release];
    [_detailsTableView release];
    [super dealloc];
}

+ (VasttrafikDetailsViewController *)controllerWithCard:(MSConfiguredBank *)card
{
    VasttrafikDetailsViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
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
        MSLVasttrafikCardServiceProxy *loginProxy = [MSLVasttrafikCardServiceProxy proxyWithUsername:self.configuredCard.ssn andPassword:self.configuredCard.password];
        
        [loginProxy performLoginWithSuccessBlock:^{
            [loginProxy fetchAccountBalance:^(NSArray *accounts) {
                // Persist the update
                [AccountUpdater persistAccountBalance:self.configuredCard accounts:accounts];
                
                NSMutableArray *parsedAccounts = [NSMutableArray array];
                NSDictionary *responseDict = [[loginProxy.balanceResponseString objectFromJSONString] valueForKey:@"d"];
                
                for (NSDictionary *cardDict in [responseDict valueForKey:@"Cards"]) {
                    NSMutableArray *cardMetaData = [NSMutableArray array];
                   
                    // Seriously weird.....
                    NSDictionary *charge = [[cardDict valueForKey:@"Charges"] firstObject];
                    double amount = [[charge valueForKey:@"Amount"] doubleValue] / 100.0;
                    
                    NSString *title = @"Saldo";
                    NSString *value = [NSString stringWithFormat:@"%.2f kr", amount];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Saldo uppd.";
                    if ([charge valueForKey:@"LastActivityDateTime"] != [NSNull null]) {
                        value = [[NSDate dateFromDotNetJSONString:[charge valueForKey:@"LastActivityDateTime"]] stringWithFormat:@"yyyy-MM-dd HH:mm"];
                    }
                    else {
                        value = @"??";
                    }
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];

                    title = @"Giltigt t.o.m";
                    value = [[NSDate dateFromDotNetJSONString:[cardDict valueForKey:@"ExpireDate"]] stringWithFormat:@"yyyy-MM-dd"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                    
                    title = @"Kortnummer";
                    value = [cardDict valueForKey:@"Number"];
                    [cardMetaData addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", value, @"value", nil]];
                   
                    NSMutableDictionary *cardInfo = [NSMutableDictionary dictionary];
                    [cardInfo setValue:[cardDict valueForKey:@"Name"] forKey:@"name"];
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
    return @"VasttrafikDetailsView";
}

@end
