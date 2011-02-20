//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SettingsView.h"
#import "MittSaldoAppDelegate.h"
#import "DebugTableViewController.h"

@implementation SettingsView
@synthesize managedObjectContext, settingsTable;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Settings", nil);
	self.managedObjectContext = ((MittSaldoAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	self.settingsTable.keyboardDelegate = self;
	
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// We plus one because the first section is general application settings
	return [[MittSaldoSettings supportedBanks] count] + 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 3)
	{
		DebugTableViewController *debugView = [[DebugTableViewController alloc] initWithNibName:@"DebugTableView" 
																						 bundle:[NSBundle mainBundle]];

		debugView.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:debugView animated:YES];
		[debugView release];
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int rows = 2;
	
	if(section == 0)
	{
		rows = 3;
		
		if([MittSaldoSettings isDebugEnabled])
			rows++;
	}
	
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	NSString *name = nil;

	if(section == 0)
	{
		name = NSLocalizedString(@"ApplicationSettings", nil);
	}
	else
	{
		name = 	[[MittSaldoSettings supportedBanks] objectAtIndex:section-1];
	}
	
	return name;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	static NSString *MyIdentifier = @"MyIdentifier";
	UITableViewCell *cell = nil;
	
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			UISwitchCell *switchCell = (UISwitchCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			switchCell.textLabel.text = NSLocalizedString(@"ApplicationLock", nil);
			[switchCell.switchControl addTarget:self action:@selector(appLockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			
			switchCell.switchControl.on = [MittSaldoSettings isKeyLockActive];
			appLockSwitch = switchCell.switchControl;
			cell = switchCell;
		}
		else if(indexPath.row == 1)
		{
			SliderCell *slidercell = (SliderCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SliderCell"];
			if(slidercell == nil)
			{
				slidercell = [[[SliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SliderCell"] autorelease];
				[slidercell.slider setMaximumValue: 60];
				[slidercell.slider setMinimumValue:1];
				slidercell.slider.value = [MittSaldoSettings multitaskingTimeout];
			}
			
			slidercell.settingsKey = @"multitaskingTimeout";
			slidercell.textLabel.text = NSLocalizedString(@"MultitaskingTimeout", nil);
			

			
			cell = slidercell;
		}
		else if(indexPath.row == 2)
		{
			UISwitchCell *switchCell = (UISwitchCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			[switchCell.switchControl addTarget:self action:@selector(debugModeChanged:) forControlEvents:UIControlEventValueChanged];
			switchCell.textLabel.text = NSLocalizedString(@"ActivateDebugMode", nil);
			switchCell.switchControl.on = [MittSaldoSettings isDebugEnabled];
			
			cell = switchCell;
		}
		else if(indexPath.row == 3)
		{
			cell = [settingsTable dequeueReusableCellWithIdentifier:@"normalcell"];
			if(cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalcell"] autorelease];
			}
			
			cell.textLabel.text = NSLocalizedString(@"DebugInformation", nil);
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
	}
	// Cells for a bank specific settings
	else if(indexPath.section > 0) 
	{		
		UITextInputCell *inputCell = (UITextInputCell*)[settingsTable dequeueReusableCellWithIdentifier:MyIdentifier];
		if (inputCell == nil) {
			inputCell = [[[UITextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		}
		
		NSString *bankIdentifier = [[MittSaldoSettings supportedBanks] objectAtIndex:indexPath.section-1];
		if(indexPath.row == 0)
		{
			inputCell.textLabel.text = NSLocalizedString(@"SSN", nil);
			inputCell.textField.text = [defaults objectForKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]];
			inputCell.textField.settingsKey = [NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier];
			inputCell.textField.secureTextEntry = NO;
			inputCell.textField.keyboardType = UIKeyboardTypeNumberPad;
		}
		else if(indexPath.row == 1)
		{
			inputCell.textLabel.text = NSLocalizedString(@"Password", nil);
			inputCell.textField.text = [defaults objectForKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]];
			inputCell.textField.settingsKey = [NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier];
			inputCell.textField.secureTextEntry = YES;
			inputCell.textField.keyboardType = UIKeyboardTypeDefault;
		}
		
		inputCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		
		inputCell.textField.delegate = self;
		cell = inputCell;
	}

	// The cells are not selectable
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (UIView *)tableView: (UITableView *)tableView viewForFooterInSection: (NSInteger)section{

	UIView *footerView = nil;
	
	if(section == 0)
	{
		footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
		footerView.autoresizesSubviews = YES;
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		footerView.userInteractionEnabled = YES;
		footerView.hidden = NO;
		footerView.multipleTouchEnabled = NO;
		footerView.opaque = NO;
		footerView.contentMode = UIViewContentModeScaleToFill;
		
		
		int xOffset = 10;
		
		if(self.view.frame.size.width > 320)
		{
			xOffset = 45;
		}
		
		

		UIButton *showHiddenAccount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[showHiddenAccount setTitle:NSLocalizedString(@"ShowAllHiddenAccounts", nil) forState:UIControlStateNormal];
		showHiddenAccount.frame = CGRectMake(xOffset, 10, self.view.frame.size.width - (xOffset *2), 40.0);
		
		
		[showHiddenAccount addTarget:self 
							  action:@selector(showHiddenAccounts:)
					forControlEvents:UIControlEventTouchDown];

		
		UIButton *clearStoredData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[clearStoredData setTitle:NSLocalizedString(@"ClearStoredBalanceInformation", nil) forState:UIControlStateNormal];
		clearStoredData.frame = CGRectMake(xOffset, 60, self.view.frame.size.width - (xOffset *2), 40.0);
		
		
		[clearStoredData addTarget:self 
							  action:@selector(clearStoredData:)
					forControlEvents:UIControlEventTouchDown];
		
		[footerView addSubview:showHiddenAccount];
		[footerView addSubview:clearStoredData];
	}
	
	return footerView;
}

// Need to call to pad the footer height otherwise the footer collapses
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 110.0;
		default:
			return 0.0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 1)
	{
		return 120; 
	}
	
	return 44;
}

#pragma mark -
#pragma mark Key lock delegate methods
-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender
{
	int comboCount = [keyCombination count];
	
	if(comboCount > 3)
	{
		[MittSaldoSettings setKeyLockCombination:keyCombination];
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[appLockSwitch setOn:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else 
	{
		[MittSaldoSettings setKeyLockCombination:nil];
		[(BSKeyLock*)sender deemKeyCombinationInvalid];
		[appLockSwitch setOn:NO];
	}
}

#pragma mark -
#pragma mark Switch delegate methods
-(IBAction)debugModeChanged:(id)sender
{
	int isOn = [(UISwitch*)sender isOn] ? 1 : 0;
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:[NSNumber numberWithInt:isOn] forKey:@"debugModeEnabled"];
	[settings synchronize];
	
	[settingsTable reloadData];
}

-(IBAction)appLockSwitchChanged:(id)sender
{
	if([(UISwitch*)sender isOn])
	{
		KeyLockViewController *keyLock = [[KeyLockViewController alloc] initWithNibName:@"KeyLockViewController" bundle:[NSBundle mainBundle] headerText:@"Ange ditt mönster"];
		keyLock.appDelegate = self;
		[self.navigationController pushViewController:keyLock animated:YES];
		[keyLock release];
		
		// Set the switch back to NO, we want the user to set a key for it to be active
		[(UISwitch*)sender setOn:NO];
	}
	else
	{
		// Clear the key lock combo
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[MittSaldoSettings setKeyLockCombination:nil];
	}
}

#pragma mark -
#pragma mark Button delegate method

-(void)showHiddenAccounts:(id)sender
{

	NSArray *accounts = [CoreDataHelper searchObjectsInContext:@"Account" 
													 predicate:[NSPredicate predicateWithFormat:@"displayAccount == 0"] 
													   sortKey:@"accountid" 
												 sortAscending:NO 
										  managedObjectContext:managedObjectContext];
	int accountsCount = [accounts count];
	
	for(int i = 0; i < accountsCount; i++)
	{
		BankAccount *a = [accounts objectAtIndex:i];
		a.displayAccount = [NSNumber numberWithInt:1];
	}
	
	
	NSError * error;
	// Store the objects
	if (![managedObjectContext save:&error]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:[error localizedDescription]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		
		// Log the error.
		NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
	}
}

-(void)clearStoredData:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:NSLocalizedString(@"ConfirmBalancePurge", nil)
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"No", nil)
										  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
	
	alert.tag = 1;
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// tag 1 = clear balance information
	if(alertView.tag == 1 && buttonIndex == 1)
	{
		// Get all accounts
		NSMutableArray* mutableFetchResults = [CoreDataHelper getObjectsFromContext:@"Account" 
																			sortKey:@"accountid" 
																	  sortAscending:NO 
															   managedObjectContext:managedObjectContext];
		
		// Delete all accounts
		for (int i = 0; i < [mutableFetchResults count]; i++) {
			[managedObjectContext deleteObject:[mutableFetchResults objectAtIndex:i]];
		}
		
		
		// Update the data model effectivly removing the objects we removed above.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
															message:[error localizedDescription]
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			
			// Log the error.
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
	}
}

#pragma mark -
#pragma mark Text Field delegate methods

// Hide the keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

// When the user focus on the textfield we move it up so that it
// is not hidden by the keyboard.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	BSSettingsTextField *settingsField = (BSSettingsTextField*)textField;
	NSIndexPath* path = [settingsTable indexPathForCell:[settingsField parentCell]];
	[self.settingsTable textFieldStatusChanged:textField scrollToIndex:path];
}

// When the user is done editing we save the setting
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// Cast the textbox to our custom class and save the input
	BSSettingsTextField *settingsField = (BSSettingsTextField*)textField;
	[settingsField saveSetting];
	
	NSIndexPath* path = [settingsTable indexPathForCell:[settingsField parentCell]];
	[self.settingsTable textFieldStatusChanged:textField scrollToIndex:path];

	
	// A swedish SSN is 10 digits. Show an alert if the entered value length isn't 10 or 12
	int length = [settingsField.text length];
	if(!settingsField.secureTextEntry && length > 0 && length != 10 && length != 12)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InputErrorQuestion", nil) 
														message:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"SSNInputError", nil), [settingsField.text length]]  
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)   
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
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
	[settingsTable release];
	[managedObjectContext release];
    [super dealloc];
}


@end
