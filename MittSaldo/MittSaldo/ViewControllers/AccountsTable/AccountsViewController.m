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

#import "AccountsViewController.h"
#import "MittSaldoSettings.h"
#import "InAppPurchaseViewController.h"
#import "MSConfiguredBank+Helper.h"
#import "NSString+Helper.h"

static int kRateAlertTag = 100;
static int kInAppPurchaseAlertTag = 200;

@interface AccountsViewController ()
@property (nonatomic, retain) AccountsTableViewController *accountsTable;
@property (nonatomic, assign) BOOL updateWhenViewAppears;
@end

@implementation AccountsViewController

- (void)dealloc
{
    [_noBanksInfoLabel release];
    [_noBanksInfoArrow release];
    [_accountsTable release];
    
    [super dealloc];
}

+ (AccountsViewController *)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MyAccounts", nil);
	self.view.backgroundColor = [UIColor whiteColor];
    
    // Add the table view
    self.accountsTable = [AccountsTableViewController controller];
    self.accountsTable.delegate = self;
    self.accountsTable.view.frame = self.view.bounds;
    [self addChildViewController:self.accountsTable];
    [self.view addSubview:self.accountsTable.view];
    self.accountsTable.view.hidden = YES;
    [self.accountsTable didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	// Important to become first responder, otherwise the shake event won't work
	[self becomeFirstResponder];
    
    NSArray *configuredServices = [MittSaldoSettings configuredBanks];
    
    if ([configuredServices count] == 0) {
        self.accountsTable.view.hidden = YES;
        self.noBanksInfoArrow.hidden = self.noBanksInfoLabel.hidden = NO;
		self.noBanksInfoLabel.text = NSLocalizedString(@"NoBanksConfigured", nil);
    }
	else {
        __block BOOL isRestoredFromIcloud = NO;
        [configuredServices enumerateObjectsUsingBlock:^(MSConfiguredBank *obj, NSUInteger idx, BOOL *stop) {
            if ([NSString stringIsNullEmpty:[obj password]]) {
                *stop = YES;
                isRestoredFromIcloud = YES;
            }
        }];
        
		self.noBanksInfoArrow.hidden = self.noBanksInfoLabel.hidden = YES;
		self.accountsTable.view.hidden = NO;
        
        if (self.updateWhenViewAppears && !isRestoredFromIcloud) {
            [self.accountsTable.tableView.pullToRefreshView triggerUpdate];
            self.updateWhenViewAppears = NO;
        }
        
        if (isRestoredFromIcloud) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"RestoreFromIcloudInformation", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
	}
    
    // Funny?
    int nr = arc4random() % 1000000;
    if (nr == 548942) {
        UIAlertView *surpriseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OneInAMillionTitle", nil) 
                                                                message:NSLocalizedString(@"OneInAMillionMessage", nil) 
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        [surpriseAlert show];
        [surpriseAlert release];        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private methods

- (void)askToBuyApp
{
    int nr = arc4random() % 200;
    
    if (nr == 100 && ![MittSaldoSettings hasPaidForApp]) {
        UIAlertView *rateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PleaseBuyAppTitle", nil)
															message:NSLocalizedString(@"PleaseBuyAppMsg", nil) 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"PleaseBuyAppMsgNo", nil) 
												  otherButtonTitles:NSLocalizedString(@"PleaseBuyAppMsgYes", nil), nil];
		rateAlert.tag = kInAppPurchaseAlertTag;
		[rateAlert show];
		[rateAlert release];
    }
}

- (void)askToRateApp
{
    int nr = arc4random() % 100;
	
	// Randomly ask the user to rate the application.
	if (![MittSaldoSettings isAppRated] && nr == 50) {
		UIAlertView *rateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PleaseRateAppTitle", nil)
															message:NSLocalizedString(@"PleaseRateAppMsg", nil) 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"Yes", nil) 
												  otherButtonTitles:NSLocalizedString(@"No", nil), NSLocalizedString(@"PleaseRateAppAlreadyRatedBtn", nil), nil];
		rateAlert.tag = kRateAlertTag;
		[rateAlert show];
		[rateAlert release];
	}
}

#pragma mark - Public methods

- (void)updateServicesWhenVisible
{
    self.updateWhenViewAppears = YES;
}

#pragma mark - AccountsTableView delegate methods

- (void)didReloadTableView
{
    [self askToRateApp];
    [self askToBuyApp];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kInAppPurchaseAlertTag && buttonIndex == 1) {
        [self.view.window.rootViewController presentModalViewController:[InAppPurchaseViewController controller] animated:YES];
    }
    else if (alertView.tag == kRateAlertTag) {
        if (buttonIndex == 0) {
            NSString *itunesURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Mitt Saldo Itunes URL"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesURL]];
        }
        else if (buttonIndex == 2) {
            [MittSaldoSettings setAlreadyRatedApp];		
        }
    }
}

#pragma mark - Methods to detect shake
// For this to work it's important that the view is first responder. That's taken
// care of in viewWillAppear and viewWillDissapear.
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	// if the motion is a shake, call the refresh accounts methods
    if (motion == UIEventSubtypeMotionShake && [self isViewLoaded]) {
        [self.accountsTable.tableView.pullToRefreshView triggerUpdate];
    }
}

// It's important to return YES here for the shake event to work
- (BOOL)canBecomeFirstResponder 
{ 
    return YES; 
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AccountsView";
}

@end
