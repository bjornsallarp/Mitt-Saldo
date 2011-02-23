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

@implementation WebBankViewController
@synthesize configuredBanks;

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
	int configuredBanksCount = [configuredBanks count];

	if(configuredBanksCount > 1)
	{
		// Reposition the view controls because the bank selection menu is visible
		bankSelectionMenu.hidden = NO;
		browserStatusView.frame = CGRectMake(0, bankSelectionMenu.frame.size.height, browserStatusView.frame.size.width, browserStatusView.frame.size.height);
		

		// Check to see which bank was visited last time
		NSString *defaultWebBank = [settings objectForKey:@"default_web_bank"];
		int defaultSegmentIndex = 0;
		
		[bankSelectionMenu removeAllSegments];
		
		for(int i = 0; i < configuredBanksCount; i++)
		{
            if(configuredBanksCount > 3)
            {
                // If more than three banks are configured we need to set the segement names to a shorter name
                // otherwise it looks weird.
                [bankSelectionMenu insertSegmentWithTitle:[MittSaldoSettings bankShortName:[configuredBanks objectAtIndex:i]] atIndex:i animated:NO];               
            }
            else
            {
                [bankSelectionMenu insertSegmentWithTitle:[configuredBanks objectAtIndex:i] atIndex:i animated:NO];
			}
            
			if([defaultWebBank isEqualToString:[configuredBanks objectAtIndex:i]])
			{
				defaultSegmentIndex = i;
			}
		}

		bankSelectionMenu.selectedSegmentIndex = defaultSegmentIndex;
	}
	else if(configuredBanksCount == 1)
	{
		// Reposition the view controls because we hide the bank selection menu
		browserStatusView.frame = CGRectMake(0, 0, browserStatusView.frame.size.width, browserStatusView.frame.size.height);
		bankSelectionMenu.hidden = YES;
		
		// Remember that this is our default bank
		[settings setObject:[configuredBanks objectAtIndex:0] forKey:@"default_web_bank"];
		[settings synchronize];
		
		// Navigate to the active bank
		[self navigateToTransferPage:[configuredBanks objectAtIndex:0]];
	}
	else 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:NSLocalizedString(@"NoAccountsConfiguredWeb", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
    
    // position and size the browser frame correctly
    webBrowser.frame = CGRectMake(0, browserStatusView.frame.origin.y+browserStatusView.frame.size.height, self.view.bounds.size.width, 
                                  self.view.bounds.size.height - (browserStatusView.frame.origin.y+browserStatusView.frame.size.height));
}


-(void)navigateToTransferPage:(NSString*)bankIdentifier
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSURL *transferurl = [NSURL URLWithString:[settings objectForKey:[NSString stringWithFormat:@"%@Transfer", bankIdentifier]]];
	
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:transferurl];
	
	// If we have cookies we don't need to authenticate
	if([cookies count] > 0 && ![bankIdentifier isEqualToString:@"Länsförsäkringar"])
	{
		// If the user is already on the transfer page there's no reason to reload that page.
		if(![[[webBrowser.request URL] absoluteString] isEqualToString:[transferurl absoluteString]])
		{
			//URL Requst Object
			NSURLRequest *requestObj = [NSURLRequest requestWithURL:transferurl];
		
			[webBrowser loadRequest:requestObj];
		}
	}
	else 
	{
		[self authenticateWithBank:bankIdentifier];
	}
}

-(void)authenticateWithBank:(NSString*)bankIdentifier
{
	if(loginHelper != nil)
	{
		[loginHelper cancelOperation];
		[loginHelper release];
		loginHelper = nil;
	}
	
	[browserActivityIndicator startAnimating];
	browserUrlLabel.text = NSLocalizedString(@"Authenticating", nil);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	loginHelper = [[BankLoginFactory createLoginProxy:bankIdentifier] retain];
	
	loginHelper.delegate = self;

	[loginHelper login:bankIdentifier];
}

#pragma mark Account updater delegate methods

-(void)loginFailed:(id<BankLogin>)sender
{	
	[browserActivityIndicator stopAnimating];
	browserUrlLabel.text = @"";
	
	// Store debug information
	if([MittSaldoSettings isDebugEnabled])
	{
		
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
	
	if(!sender.wasCancelled)
	{
		// If the updater carries an error message something anticipated is wrong.
		if(sender.errorMessage != nil)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccountUpdateErrorMessageTitle", nil)
															message:sender.errorMessage
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)  
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
		else
		{
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
	
	[loginHelper release];
	loginHelper = nil;
}

-(void)loginSucceeded:(id<BankLogin>)sender
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;		
	[browserActivityIndicator stopAnimating];
	

	if([sender.settings.bankIdentifier isEqualToString:@"Länsförsäkringar"])
	{
		[webBrowser loadHTMLString:[sender performSelector:@selector(loginResponse)] baseURL:sender.settings.loginURL];
	}
	else {
		
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		//Create a URL object.
		NSURL *transferurl = [NSURL URLWithString:[settings objectForKey:[NSString stringWithFormat:@"%@Transfer", sender.settings.bankIdentifier]]];	
		
		//URL Requst Object
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:transferurl];
		
		[webBrowser loadRequest:requestObj];		
	}


	[loginHelper release];
	loginHelper = nil;
}

-(void)checkIfLoggedOut:(NSString*)loadingUrl
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSString *currentBankLogin = [settings objectForKey:[NSString stringWithFormat:@"%@Login", [settings objectForKey:@"default_web_bank"]]];
	
	// check if the user is heading to the loginpage of the active bank
	if([loadingUrl hasPrefix:currentBankLogin])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TransferMoneyLoggedOutTitle", nil)
														message:NSLocalizedString(@"TransferMoneyLoggedOutMsg", nil)
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"No", nil) 
											  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
		
		[alert show];
		[alert release];
	}
	
}

-(NSString*)selectedBank
{
    return [self.configuredBanks objectAtIndex:[bankSelectionMenu selectedSegmentIndex]];
}

#pragma mark -
#pragma mark Segmented control event

- (void)webBankChanged:(id)sender
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:[self selectedBank] forKey:@"default_web_bank"];
	[settings synchronize];
	
	[self navigateToTransferPage:[self selectedBank]];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

// There's only one alert view with buttons. That's in the "checkIfLoggedOut" method. 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// If ther user wants to login again we're happy to do so
	if(buttonIndex == 1)
	{
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		
		// Clear cookies 
		[MittSaldoSettings removeCookiesForBank:[settings objectForKey:@"default_web_bank"]];
		
		// And go again!
		[self navigateToTransferPage:[settings objectForKey:@"default_web_bank"]];
	}
}

#pragma mark -
#pragma mark Web view delegate methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	browserUrlLabel.text = [[request URL] absoluteString];

	if([[self selectedBank] isEqualToString:@"Länsförsäkringar"] == NO)
	{
		[self performSelectorOnMainThread:@selector(checkIfLoggedOut:) withObject:browserUrlLabel.text waitUntilDone:NO];
	}
	
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[browserActivityIndicator stopAnimating];	
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[browserActivityIndicator startAnimating];
}

#pragma mark -
#pragma mark Memmory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[loginHelper cancelOperation];
	[loginHelper release];
	[configuredBanks release];
	
	// Outlets
	[webBrowser release];
	[browserStatusView release];
	[browserUrlLabel release];
	[browserActivityIndicator release];
	[bankSelectionMenu release];
		
    [super dealloc];
}


@end
