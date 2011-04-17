//
//  Created by Björn Sållarp on 2010-05-23.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "WebBankViewController.h"
#import "MittSaldoAppDelegate.h"
#import "BankLoginFactory.h"

@interface WebBankViewController()
@property (nonatomic, retain) id<BankLogin, NSObject> loginHelper;
@property (nonatomic, retain) NSArray *configuredBanks;
@property (nonatomic, retain) BankSettings *selectedBankSettings;
@end

@implementation WebBankViewController
@synthesize configuredBanks = configuredBanks_;
@synthesize loginHelper = loginHelper_;
@synthesize selectedBankSettings = selectedBankSettings_;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	bankSelectionMenu.tintColor = [UIColor darkGrayColor];
	webBrowser.delegate = self;
	
	[bankSelectionMenu addTarget:self
						 action:@selector(webBankChanged:)
			   forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	self.configuredBanks = [MittSaldoSettings configuredBanks];
	int configuredBanksCount = [self.configuredBanks count];

	if (configuredBanksCount > 1) {
		bankSelectionMenu.hidden = NO;
        
        float height = (self.view.bounds.size.height - bankSelectionMenu.bounds.size.height) - browserStatusView.bounds.size.height;
        webBrowser.frame = CGRectMake(0, bankSelectionMenu.frame.size.height, self.view.bounds.size.width, height);
        
		// Check to see which bank was visited last time
		NSString *defaultWebBank = [settings objectForKey:@"default_web_bank"];
		int defaultSegmentIndex = 0;
		
		[bankSelectionMenu removeAllSegments];
		
		for (int i = 0; i < configuredBanksCount; i++) {
            if(configuredBanksCount > 3) {
                // If more than three banks are configured we need to set the segement names to a shorter name
                // otherwise it looks weird.
                [bankSelectionMenu insertSegmentWithTitle:[MittSaldoSettings bankShortName:[self.configuredBanks objectAtIndex:i]] atIndex:i animated:NO];               
            }
            else {
                [bankSelectionMenu insertSegmentWithTitle:[self.configuredBanks objectAtIndex:i] atIndex:i animated:NO];
			}
            
			if ([defaultWebBank isEqualToString:[self.configuredBanks objectAtIndex:i]]) {
				defaultSegmentIndex = i;
			}
		}

		bankSelectionMenu.selectedSegmentIndex = defaultSegmentIndex;
	}
	else if (configuredBanksCount == 1) {
        bankSelectionMenu.hidden = YES;
        float height = self.view.bounds.size.height - browserStatusView.bounds.size.height;
		webBrowser.frame = CGRectMake(0, 0, self.view.bounds.size.width, height);
        
		// Remember that this is our default bank
		[settings setObject:[self.configuredBanks objectAtIndex:0] forKey:@"default_web_bank"];
		[settings synchronize];
		
		// Navigate to the active bank
		[self navigateToTransferPage:[self.configuredBanks objectAtIndex:0]];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:NSLocalizedString(@"NoAccountsConfiguredWeb", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}


- (void)navigateToTransferPage:(NSString*)bankIdentifier
{
    self.selectedBankSettings = [BankSettings settingsForBank:bankIdentifier];
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.selectedBankSettings.bookmarkedURL];
	
	// If we have cookies we don't need to authenticate
	if ([cookies count] > 0 && ![bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
		// If the user is already on the transfer page there's no reason to reload that page.
		if (![[[webBrowser.request URL] absoluteString] isEqualToString:[self.selectedBankSettings.bookmarkedURL absoluteString]]) {
            [webBrowser loadRequest:[NSURLRequest requestWithURL:self.selectedBankSettings.bookmarkedURL]];
		}
	}
	else {
		[self authenticateWithBank:bankIdentifier];
	}
}

-(void)authenticateWithBank:(NSString*)bankIdentifier
{
	if (self.loginHelper) {
		[self.loginHelper cancelOperation];
		self.loginHelper = nil;
	}

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[browserActivityIndicator startAnimating];
    [bookmarkButton setHidden:YES];
	browserUrlLabel.text = NSLocalizedString(@"Authenticating", nil);
	
	self.loginHelper = [BankLoginFactory createLoginProxy:bankIdentifier];
	self.loginHelper.delegate = self;
	[self.loginHelper login:bankIdentifier];
}

#pragma mark Account updater delegate methods

-(void)loginFailed:(id<BankLogin>)sender
{	
	[browserActivityIndicator stopAnimating];
	browserUrlLabel.text = @"";
	
	// Store debug information
	if ([MittSaldoSettings isDebugEnabled]) {
		
		NSManagedObjectContext *managedObjectContext = ((MittSaldoAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
		LogEntry *toStore = (LogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" 
																	  inManagedObjectContext:managedObjectContext];
		
		toStore.Bank = sender.debugLog.Bank;
		toStore.DateAdded = [NSDate date];
		toStore.Content = sender.debugLog.Content;
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error?
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
	}
	
	if (!sender.wasCancelled) {
		// If the updater carries an error message something anticipated is wrong.
		if(sender.errorMessage != nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccountUpdateErrorMessageTitle", nil)
															message:sender.errorMessage
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)  
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
		else {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccountUpdateErrorMessageTitle", nil) 
															message:NSLocalizedString(@"AccountUpdateErrorMessage", nil) 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
	}
	
	self.loginHelper = nil;
}

-(void)loginSucceeded:(id<BankLogin>)sender
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;		
	[browserActivityIndicator stopAnimating];
    [bookmarkButton setHidden:NO];
	
	if ([sender.settings.bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
		[webBrowser loadHTMLString:[sender performSelector:@selector(loginResponse)] baseURL:sender.settings.loginURL];
	}
	else {
		[webBrowser loadRequest:[NSURLRequest requestWithURL:sender.settings.bookmarkedURL]];		
	}


    self.loginHelper = nil;
}

-(void)checkIfLoggedOut:(NSString*)loadingUrl
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *currentBankLogin = [settings objectForKey:[NSString stringWithFormat:@"%@Login", [settings objectForKey:@"default_web_bank"]]];
	
	// check if the user is heading to the loginpage of the active bank
	if ([loadingUrl hasPrefix:currentBankLogin]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TransferMoneyLoggedOutTitle", nil)
														message:NSLocalizedString(@"TransferMoneyLoggedOutMsg", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"No", nil) 
											  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		alert.tag = 1;
		[alert show];
		[alert release];
	}
	
}

#pragma mark - UI Events
- (void)webBankChanged:(id)sender
{
    NSString *selectedBankIdentifier = [self.configuredBanks objectAtIndex:[bankSelectionMenu selectedSegmentIndex]];
    
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:selectedBankIdentifier forKey:@"default_web_bank"];
	[settings synchronize];
	    
	[self navigateToTransferPage:selectedBankIdentifier];
}

- (IBAction)bookmarkPage:(id)sender
{
    UIAlertView *bookmarkAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WebBankBookmarkAlertTitle", nil)
                                                            message:NSLocalizedString(@"WebBankBookmarkAlertMessage", nil) 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"No", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    bookmarkAlert.tag = 2;
    [bookmarkAlert show];
    [bookmarkAlert release];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        // If ther user wants to login again we're happy to do so
        if (buttonIndex == 1) {
            // Clear cookies And go again!
            [MittSaldoSettings removeCookiesForBank:self.selectedBankSettings.bankIdentifier];
            [self navigateToTransferPage:self.selectedBankSettings.bankIdentifier];
        }
	}
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            self.selectedBankSettings.bookmarkedURL = [NSURL URLWithString:browserUrlLabel.text];
            [self.selectedBankSettings save];
        }
    }
}

#pragma mark -
#pragma mark Web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	browserUrlLabel.text = [[request URL] absoluteString];

	if (![self.selectedBankSettings.bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
		[self performSelectorOnMainThread:@selector(checkIfLoggedOut:) withObject:browserUrlLabel.text waitUntilDone:NO];
	}
	
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[browserActivityIndicator stopAnimating];
    
    if (![self.selectedBankSettings.bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
        [bookmarkButton setHidden:NO];
    }
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[browserActivityIndicator startAnimating];
    [bookmarkButton setHidden:YES];
}

#pragma mark -
#pragma mark Memmory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}


- (void)dealloc 
{
	[self.loginHelper cancelOperation];
	self.loginHelper = nil;
	self.configuredBanks = nil;
    self.selectedBankSettings = nil;
	
	// Outlets
	[webBrowser release];
	[browserStatusView release];
	[browserUrlLabel release];
	[browserActivityIndicator release];
	[bankSelectionMenu release];
    [bookmarkButton release];
		
    [super dealloc];
}


@end
