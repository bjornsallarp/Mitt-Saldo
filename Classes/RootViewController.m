//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "RootViewController.h"
#import "MittSaldoAppDelegate.h"
#import "AccountInfoTableView.h"

@interface RootViewController()
- (void)onetimeCleanupForBank:(NSString *)bankIdentifier uniqueKey:(NSString *)uniqueKey message:(NSString *)message;
@end

@implementation RootViewController
@synthesize managedObjectContext, tableRows, tableSections, updatingLabel, tableView;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"MyAccounts", nil);
	self.managedObjectContext = ((MittSaldoAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	// initing the bar button
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																				   target:self 
																				   action:@selector(refreshAccounts:)];
	self.navigationItem.leftBarButtonItem = refreshButton;
	[refreshButton release];
	
	// Style the update label using layers
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = updatingLabelBackgroundView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[RGB(237,238,240) CGColor], (id)[RGB(195,197,201) CGColor], nil];
	[updatingLabelBackgroundView.layer insertSublayer:gradient atIndex:0];
	
	CALayer *topLine = [CALayer layer];
	topLine.frame = CGRectMake(0, 0, updatingLabelBackgroundView.frame.size.width, 1);
	topLine.backgroundColor = [RGB(187,189,190) CGColor];
	[updatingLabelBackgroundView.layer insertSublayer:topLine atIndex:1];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // The update changes the way accounts are parsed and stored so we clean that up with a friendly message.
    [self onetimeCleanupForBank:@"Swedbank" uniqueKey:@"cleanupSwedbank20110513" message:NSLocalizedString(@"cleanupSwedbank20110513", nil)];
    

	// Important to become first responder, otherwise the shake event won't work
	[self becomeFirstResponder];
    	
	// Load account data
	[self reloadTableView];
    
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


-(IBAction)showHiddenAccounts:(id)sender
{
	showHiddenAccounts = !showHiddenAccounts;
	
	UIBarButtonItem *senderBtn = sender;

	if(showHiddenAccounts)
	{
		senderBtn.image = [UIImage imageNamed:@"eye_black.png"];
	}
	else 
	{
		senderBtn.image = [UIImage imageNamed:@"eye.png"];
	}

	

	[self reloadTableView];
}


// Connects to the configured banks and downloads account balance
-(IBAction)refreshAccounts:(id)sender
{
	NSArray *configuredBanks = [MittSaldoSettings configuredBanks];

	if([configuredBanks count] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:NSLocalizedString(@"NoAccountsConfigured", nil)
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)   
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else if(banksToUpdate == nil)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		// Add an activity indicator to the refresh button
		CGRect frame = CGRectMake(0.0, 2.0, 25.0, 25.0);
		UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		[loading startAnimating];
		[loading sizeToFit];
		loading.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
		
		// initing the bar button
		UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:loading];
		[loading release];
		
		loadingView.target = self;
		loadingView.action = @selector(refreshAccounts:);
		self.navigationItem.leftBarButtonItem = loadingView;
		[loadingView release];
		
		NSArray *allBanks = [MittSaldoSettings supportedBanks];
		
		banksToUpdate = [[NSMutableArray alloc] init];
		
		// Start updating each configured bank
		for(NSString *bankIdentifier in allBanks)
		{
			if([MittSaldoSettings isBankConfigured:bankIdentifier])
			{
				// Queue banks to update
				AccountUpdater *updater = [[AccountUpdater alloc] initWithDelegateAndContext:self 
																					 context:managedObjectContext];
				updater.bankIdentifier = bankIdentifier;
				[banksToUpdate addObject:updater];
				[updater release];
			}
			else
			{
				// Remove accounts if the bank is no longer configured
				[self removeAccountsForBank:bankIdentifier];				
			}
		}
		
		// Start updating the first bank
		AccountUpdater *updater = [banksToUpdate objectAtIndex:0];
		
		updatingLabelBackgroundView.hidden = NO;
		updatingLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Updating", nil), updater.bankIdentifier];
		
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		CGRect tableRect = self.tableView.frame;
		tableRect.size.height -= updatingLabelBackgroundView.frame.size.height;
		self.tableView.frame = tableRect;
		[UIView commitAnimations];
		
		[updater retrieveAccounts];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

- (void)onetimeCleanupForBank:(NSString *)bankIdentifier uniqueKey:(NSString *)uniqueKey message:(NSString *)message
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if ([settings valueForKey:uniqueKey] == nil) {
        NSArray *accounts = [CoreDataHelper searchObjectsInContext:@"Account" 
                                                         predicate:[NSPredicate predicateWithFormat:@"bankIdentifier == %@", bankIdentifier] 
                                                           sortKey:@"accountid" 
                                                     sortAscending:NO 
                                              managedObjectContext:managedObjectContext];
        
        int accountsCount = [accounts count];
        if (accountsCount > 0) {
            
            UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"" 
                                                                  message:message
                                                                 delegate:nil 
                                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                        otherButtonTitles:nil, nil];
            [deleteAlert show];
            [deleteAlert release];
            
            for(int i = 0; i < accountsCount; i++)
            {
                [managedObjectContext deleteObject:[accounts objectAtIndex:i]];
            }
            
            NSError * error;
            // Store the objects
            if (![managedObjectContext save:&error]) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                                message:[error localizedDescription]
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
                // Log the error.
                NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
            }
        }        
        
        // Remember that we did this
        [settings setValue:@"done" forKey:uniqueKey];
        [settings synchronize];
    }
}

-(void)removeAccountsForBank:(NSString *)bankIdentifier
{
	NSArray *accounts = [CoreDataHelper searchObjectsInContext:@"Account" 
													 predicate:[NSPredicate predicateWithFormat:@"bankIdentifier == %@", bankIdentifier] 
													   sortKey:@"accountid" 
												 sortAscending:NO 
										  managedObjectContext:managedObjectContext];

	int accountsCount = [accounts count];
	
	for(int i = 0; i < accountsCount; i++)
	{
		[managedObjectContext deleteObject:[accounts objectAtIndex:i]];
	}
	
	NSError * error;
	// Store the objects
	if (![managedObjectContext save:&error]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:[error localizedDescription]
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		
		// Log the error.
		NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		
	}
}

-(void)bankUpdated:(id)sender
{
	// Bank is updated, remove from queue
	[banksToUpdate removeObject:sender];
	

	if([banksToUpdate count] == 0)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		CGRect tableRect = self.tableView.frame;
		tableRect.size.height += updatingLabelBackgroundView.frame.size.height;
		self.tableView.frame = tableRect;
		[UIView commitAnimations];
		
		updatingLabel.text = @"";
		
		// If there are no more banks to update change the toolbar button back		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// initing the bar button
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
																					   target:self 
																					   action:@selector(refreshAccounts:)];
		self.navigationItem.leftBarButtonItem = refreshButton;
		[refreshButton release];
		
		// Free our queue
		[banksToUpdate release];
		banksToUpdate = nil;
		
		// Reload the table
		[self reloadTableView];
	}
	else 
	{
		AccountUpdater *updater = [banksToUpdate objectAtIndex:0];
		updatingLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Updating", nil), updater.bankIdentifier];
		// Update next bank  in queue
		[updater retrieveAccounts];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

#pragma mark -
#pragma mark Account Updater delegate methods
-(void)accountsUpdatedError:(id)sender
{
	NSString *bankIdentifer = [((AccountUpdater*)sender).bankIdentifier retain];
	NSString *errorMessage = [((AccountUpdater*)sender).errorMessage retain];
	
	[self bankUpdated:sender];
	
	// If the updater carries an error message something anticipated is wrong.
	if(errorMessage != nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:bankIdentifer 
														message:errorMessage
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:bankIdentifer
														message:NSLocalizedString(@"AccountUpdateErrorMessage", nil)
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	
	// If something went wrong we remove the cookies so next update starts out fresh
	[MittSaldoSettings removeCookiesForBank:bankIdentifer];
	
	[bankIdentifer release];
	[errorMessage release];
}


-(void)accountsUpdated:(id)sender
{
	[self bankUpdated:sender];
}

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://blog.sallarp.com/mittsaldoitunes"]];
	}
	else if(buttonIndex == 2)
	{
		[MittSaldoSettings setAlreadyRatedApp];		
	}
}


#pragma mark -
#pragma mark Table view data source

-(void) loadAccounts
{
	NSPredicate *hideHiddenAccountsPredicate = nil;
	
	
	// Grab all hidden accounts
	int nrOfHiddenAccounts = [[CoreDataHelper searchObjectsInContext:@"Account" 
														   predicate:[NSPredicate predicateWithFormat:@"(displayAccount == 0)"]  
															 sortKey:@"bankIdentifier,accountid" 
													   sortAscending:YES 
												managedObjectContext:managedObjectContext] count];
	
	
	// If there are hidden accounts, show the button to toggle hidden accounts
	if(nrOfHiddenAccounts > 0 && self.navigationItem.rightBarButtonItem == nil)
	{
		UIBarButtonItem *viewHiddenAccountsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eye.png"] 
																					 style:UIBarButtonItemStyleBordered 
																					target:self 
																					action:@selector(showHiddenAccounts:)];
		
		self.navigationItem.rightBarButtonItem = viewHiddenAccountsButton;
		[viewHiddenAccountsButton release];
	}
	// Remove the toggle button if it is visible and there are no hidden accounts.
	else if(nrOfHiddenAccounts == 0 && self.navigationItem.rightBarButtonItem != nil)
	{
		self.navigationItem.rightBarButtonItem = nil;
	}
	
	
	// If we're only showing accounts not marked as hidden we need a predicate (query) for this
	if(!showHiddenAccounts)
	{
		hideHiddenAccountsPredicate = [NSPredicate predicateWithFormat:@"(displayAccount == 1)"];
	}
	
	NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
																	   predicate:hideHiddenAccountsPredicate  
																		 sortKey:@"bankIdentifier,accountid" 
																   sortAscending:YES 
															managedObjectContext:managedObjectContext];
		
	if([mutableFetchResults count] == 0)
	{
		self.tableView.hidden = YES;
		updatingLabelBackgroundView.hidden = YES;
		noAccountInfoLabel.hidden = NO;
		noAccountInfoLabel.text = NSLocalizedString(@"NoAccountsUpdated", nil);
	}
	else 
	{
		noAccountInfoLabel.hidden = YES;
		self.tableView.hidden = NO;
		updatingLabelBackgroundView.hidden = NO;
	}


	
	int arrayLength = [mutableFetchResults count];
	
	self.tableSections = [[[NSMutableArray alloc] init] autorelease];
	self.tableRows = [[[NSMutableDictionary alloc] init] autorelease];
	
	totalAccountsAmount = 0;
	
	for (int i = 0; i < arrayLength; i++) {
		BankAccount *a = [mutableFetchResults objectAtIndex:i];
		
		totalAccountsAmount += [a.amount floatValue];
		
		if ([tableRows objectForKey:a.bankIdentifier] == nil) {
			[tableSections addObject:a.bankIdentifier];
			
			NSMutableArray *entities = [[NSMutableArray alloc] init];
			[entities addObject:a];
			[tableRows setObject:entities forKey:a.bankIdentifier];
			[entities release];
		}
		else 
		{
			NSMutableArray *entities = [tableRows objectForKey:a.bankIdentifier];
			[entities addObject:a];
		}
	}
}

-(void)reloadTableView
{
	[self loadAccounts];
	[self.tableView reloadData];
	
	int nr = arc4random() % 100;
	
	// Randomly ask the user to rate the application.
	if(nr == 50 && ![MittSaldoSettings isAppRated])
	{
		UIAlertView *rateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PleaseRateAppTitle", nil)
															message:NSLocalizedString(@"PleaseRateAppMsg", nil) 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"Yes", nil) 
												  otherButtonTitles:NSLocalizedString(@"No", nil), NSLocalizedString(@"PleaseRateAppAlreadyRatedBtn", nil), nil];
		
		[rateAlert show];
		[rateAlert release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section < [tableSections count])
	{
		NSManagedObject *object = (NSManagedObject *)[[tableRows objectForKey:[tableSections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	
		if([object valueForKey:@"availableAmount"] != nil)
		{
			return 64.0;
		}
	}

	return 44.0;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	
	int sections = [tableSections count];
	
	if(sections > 0)
	{
		// Add section for totals
		sections++;
	}
	
	return sections;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	int rowsInSection = 0;
	
	if(section < [tableSections count])
	{
		rowsInSection = [[tableRows objectForKey:[tableSections objectAtIndex:section]] count];
	}
	else
	{
		// This is for the totals section. We just have one row
		rowsInSection = 1;
	}

	
	return rowsInSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionTitle = nil;
	
	if(section < [tableSections count])
	{
		sectionTitle = [tableSections objectAtIndex:section];
		
		BankAccount *a = [[tableRows valueForKey:sectionTitle] objectAtIndex:0];
		
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"d/MM HH:mm"];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
		sectionTitle = [NSString stringWithFormat:@"%@ (%@)", sectionTitle,	[dateFormatter stringFromDate:a.updatedDate]];
	}
	else 
	{
		// The title for the totals section
		sectionTitle = NSLocalizedString(@"TotalBalance", nil);
	}

	
	return sectionTitle;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	NSNumberFormatter *currencyStyle = [[[NSNumberFormatter alloc] init] autorelease];
	
	// set options.
	[currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyStyle setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
	
	
	if(indexPath.section > [tableSections count]-1)
	{
		static NSString *totalsCellIdentifier = @"TotalsCell";
		cell = [sender dequeueReusableCellWithIdentifier:totalsCellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:totalsCellIdentifier] autorelease];
			cell.contentView.backgroundColor = [UIColor whiteColor];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
		}
		
		cell.textLabel.backgroundColor = [UIColor whiteColor];
		cell.textLabel.text = [NSString stringWithFormat:@"%@", [currencyStyle stringFromNumber:[NSNumber numberWithFloat:totalAccountsAmount]]];
	}
	else 
	{
		NSManagedObject *object = (NSManagedObject *)[[tableRows objectForKey:[tableSections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		
		NSString *CellIdentifier = @"Cell";
		BOOL availableAmount = [object valueForKey:@"availableAmount"] != nil;
		
		if(availableAmount)
		{
			CellIdentifier = @"AvailableCell";
		}		
		
		cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil) {
			cell = [[[AccountInfoTableView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier showAvailableAmount:availableAmount] autorelease];
			
			cell.contentView.backgroundColor = [UIColor whiteColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		AccountInfoTableView *accountCell = (AccountInfoTableView*)cell;
		

		accountCell.accountTitle.text = [NSString stringWithFormat:@"%@", [object valueForKey:@"displayName"]];
		accountCell.accountAmount.text = [NSString stringWithFormat:@"%@: %@.", NSLocalizedString(@"AccountBalance", nil), 
										  [currencyStyle stringFromNumber:[object valueForKey:@"amount"]]];
		
		if(availableAmount)
		{
			accountCell.accountAvailableAmount.text = [NSString stringWithFormat:@"%@: %@.", NSLocalizedString(@"AvailableAccountBalance", nil), 
													   [currencyStyle stringFromNumber:[object valueForKey:@"availableAmount"]]];
		}
		
	}
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if(indexPath.section < [tableSections count])
	{
		// Get the object the user selected from the array
		BankAccount *selectedAccount = [[tableRows objectForKey:[tableSections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
		
		
		AccountDetailsView *detailViewController = [[AccountDetailsView alloc] initWithNibName:@"AccountDetailsView" bundle:[NSBundle mainBundle] account:selectedAccount];
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	}
}

#pragma mark -
#pragma mark Methods to detect shake
// For this to work it's important that the view is first responder. That's taken
// care of in viewWillAppear and viewWillDissapear.
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	// if the motion is a shake, call the refresh accounts methods
    if(motion == UIEventSubtypeMotionShake && [self isViewLoaded])
    {
		[self refreshAccounts:nil];
    }
}

// It's important to return YES here for the shake event to work
- (BOOL)canBecomeFirstResponder 
{ 
    return YES; 
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	
	[managedObjectContext release];
	[tableRows release];
	[tableSections release];
	
	// Outlets
	[tableView release];
	[updatingLabelBackgroundView release];
	[updatingLabel release];
	[noAccountInfoLabel release];
	
    [super dealloc];
}


@end

