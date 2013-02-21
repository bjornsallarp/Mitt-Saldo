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

#import "TicketRikskortetDetailsViewController.h"
#import "MSConfiguredBank+Helper.h"
#import "BSPullToRefresh.h"
#import "MSLParsedAccount.h"
#import "MSLTicketRikskortetServiceProxy.h"
#import "MSLTicketRikskortetTransaction.h"
#import "AccountUpdater.h"
#import "UIAlertView+MSHelper.h"

@interface TicketRikskortetDetailsViewController ()
@property (nonatomic, retain) NSArray *transactions;
@property (nonatomic, assign) double balance;
@end

@implementation TicketRikskortetDetailsViewController

- (void)dealloc
{
    [_transactions release];
    [_detailsTableView release];
    [super dealloc];
}

+ (TicketRikskortetDetailsViewController *)controllerWithCard:(MSConfiguredBank *)card
{
    TicketRikskortetDetailsViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
    controller.configuredCard = card;
    
    return [controller autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.balance = FLT_MIN;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    MSLServiceFailureBlock failureBlock = ^(NSError *error, NSString *errorMessage) {
        [self.detailsTableView.pullToRefreshView stopAnimating];
        [UIAlertView showUpdateDidFailAlertForBank:self.configuredCard error:error message:errorMessage errorReportingDelegate:self];
    };
    
    [self.detailsTableView addPullToRefreshWithActionHandler:^{
        MSLTicketRikskortetServiceProxy *loginProxy = [MSLTicketRikskortetServiceProxy proxyWithUsername:self.configuredCard.ssn andPassword:self.configuredCard.password];
        
        [loginProxy performLoginWithSuccessBlock:^{
            [loginProxy fetchAccountBalance:^(NSArray *accounts) {
                [AccountUpdater persistAccountBalance:self.configuredCard accounts:accounts];

                self.transactions = loginProxy.transactions;
                
                MSLParsedAccount *account = [accounts lastObject];
                self.balance = [account.amount doubleValue];
                
                [self.detailsTableView reloadData];
                [self.detailsTableView.pullToRefreshView stopAnimating];
                
            } failure:failureBlock];
        } failure:failureBlock];
    }];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 55;
    
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CardDetailsTableHeaderView *header = [CardDetailsTableHeaderView view];
    header.title = section == 0 ? @"Saldo" : @"Transaktioner";
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return MAX(1, [self.transactions count]);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if (indexPath.section == 0) {
		static NSString *balanceCell = @"BalanceCell";
        cell = [tableView dequeueReusableCellWithIdentifier:balanceCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:balanceCell] autorelease];
        }
    
        cell.textLabel.font = [UIFont systemFontOfSize:35];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        if (self.balance != FLT_MIN) {
            cell.textLabel.text = [NSString stringWithFormat:@"%.2f kr", self.balance];            
        }
    }
    else {
		static NSString *transactionCell = @"TransactionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:transactionCell];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:transactionCell] autorelease];
            
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(cell.frame)-120, 35)];
            descriptionLabel.numberOfLines = 2;
            descriptionLabel.tag = 100;
            descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
            descriptionLabel.font = [UIFont systemFontOfSize:12];
            descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [cell.contentView addSubview:descriptionLabel];
            [descriptionLabel release];
            
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, CGRectGetWidth(cell.frame)-120, 15)];
            dateLabel.numberOfLines = 1;
            dateLabel.tag = 101;
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:10];
            dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:dateLabel];
            [dateLabel release];            
            
        }
        
        if ([self.transactions count] > 0) {
            MSLTicketRikskortetTransaction *transaction = [self.transactions objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ kr", transaction.amount];
            
            if ([transaction.amount hasPrefix:@"-"])
                cell.detailTextLabel.textColor = [UIColor redColor];
            else 
                cell.detailTextLabel.textColor = [UIColor greenColor];
            
            UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:100];
            textLabel.text = transaction.description;
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"yyyy-MM-dd HH:mm";
            UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:101];
            dateLabel.text = [df stringFromDate:transaction.date];
            [df release];            
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
    return @"TicketRikskortetDetailsView";
}

@end
