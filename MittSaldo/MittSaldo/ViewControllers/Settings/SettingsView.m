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
#import "AvailableBanksTableViewController.h"
#import "BankSettingsViewController.h"
#import "MSConfiguredBank.h"
#import "MSBankAccount.h"
#import "UISwitchCell.h"
#import "SliderCell.h"
#import "MittSaldoSettings.h"
#import "KeyLockViewController.h"

#ifdef TACTIVO
#import "PBReferenceDatabase.h"
#import "PBBiometryUser.h"
#import "PBManageFingersController.h"
#endif

@interface SettingsView ()
@property (nonatomic, retain) NSArray *configuredBanks;
@property (nonatomic, retain) UISwitch *appLockSwitch;
@property (nonatomic, retain) UISwitch *tactivoAppLockSwitch;
@property (nonatomic, retain) UISwitch *autoUpdateOnAppStartSwitch;
@end

@implementation SettingsView

- (void)dealloc
{
    [_autoUpdateOnAppStartSwitch release];
    [_tactivoAppLockSwitch release];
    [_appLockSwitch release];
    [_configuredBanks release];
	[_settingsTable release];
    [super dealloc];
}

+ (id)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.configuredBanks = [MittSaldoSettings configuredBanks];
    [self.settingsTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row >= [self.configuredBanks count]) {
            [self.navigationController pushViewController:[AvailableBanksTableViewController controller] animated:YES];
        }
        else {
            MSConfiguredBank *bank = [self.configuredBanks objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:[BankSettingsViewController bankSettingsTableWithConfiguredBank:bank] animated:YES];
        }
    }
}


#pragma mark - Table view data source
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	int rows = 0;
	
	if (section == 0) {
		rows = 4;
    }
    else {
        rows = [self.configuredBanks count] + 1;
    }
	
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section > 0 ? 35 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    int indentation = IDIOM == IPAD ? 50 : 20;
    
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(indentation, 0, 0, 0)] autorelease];
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    headerLabel.text = [NSLocalizedString(@"Banker & kort", nil) uppercaseString];
    headerLabel.textColor = RGB(83, 86, 87);
    headerLabel.shadowColor = RGB(244, 245, 246);
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    
    UIView *bg = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [bg addSubview:headerLabel];
    return bg;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
        
        if (indexPath.row == 2) {
			SliderCell *slidercell = (SliderCell *)[self.settingsTable dequeueReusableCellWithIdentifier:@"SliderCell"];
			if (slidercell == nil) {
				slidercell = [[[SliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SliderCell"] autorelease];
				[slidercell.slider setMaximumValue: 60];
				[slidercell.slider setMinimumValue:1];
                slidercell.slider.value = [MittSaldoSettings multitaskingTimeout];
			}
			
			slidercell.settingsKey = @"multitaskingTimeout";
			slidercell.textLabel.text = NSLocalizedString(@"MultitaskingTimeout", nil);
            
			cell = slidercell;
		}
        else {
            UISwitchCell *switchCell = (UISwitchCell*)[self.settingsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
            if (indexPath.row == 0) {
                switchCell.textLabel.text = NSLocalizedString(@"ApplicationLock", nil);
                [switchCell.switchControl addTarget:self action:@selector(appLockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                switchCell.switchControl.on = [MittSaldoSettings isKeyLockActive];
                self.appLockSwitch = switchCell.switchControl;
            }
            else if (indexPath.row == 1) {
                switchCell.textLabel.text = NSLocalizedString(@"TactivoApplicationLock", nil);
                [switchCell.switchControl addTarget:self action:@selector(tactivoappLockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                switchCell.switchControl.on = [MittSaldoSettings isTactivoLockActive];
                self.tactivoAppLockSwitch = switchCell.switchControl;
            }
            else if (indexPath.row == 3) {
                switchCell.textLabel.text = NSLocalizedString(@"Uppdatera vid start", nil);
                [switchCell.switchControl addTarget:self action:@selector(updateOnStartSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                switchCell.switchControl.on = [MittSaldoSettings isUpdateOnStartEnabled];
                self.autoUpdateOnAppStartSwitch = switchCell.switchControl;
            }
            
			cell = switchCell;
        }
        
        // The cells are not selectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	// Cells for a bank specific settings
	else if (indexPath.section > 0) {
        
        cell = [self.settingsTable dequeueReusableCellWithIdentifier:@"normalcell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalcell"] autorelease];
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row < [self.configuredBanks count]) {
            MSConfiguredBank *bank = [self.configuredBanks objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", bank.name, bank.bankIdentifier];
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"Lägg till bank / kort", nil);
        }
	}

    cell.backgroundColor = RGB(237, 242, 244);

	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *footerView = nil;
	
	if (section == 0) {
		footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)] autorelease];
		footerView.autoresizesSubviews = YES;
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		footerView.userInteractionEnabled = YES;
		footerView.hidden = NO;
		footerView.multipleTouchEnabled = NO;
		footerView.opaque = NO;
		footerView.contentMode = UIViewContentModeScaleToFill;
		
        int xOffset = IDIOM == IPAD ? 45 : 10;
		
		UIButton *showHiddenAccount = [UIButton buttonWithType:UIButtonTypeCustom];
        [showHiddenAccount setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
		[showHiddenAccount setTitle:NSLocalizedString(@"ShowAllHiddenAccounts", nil) forState:UIControlStateNormal];
		showHiddenAccount.frame = CGRectMake(xOffset, 10, footerView.bounds.size.width - (xOffset*2), 40.0);
		showHiddenAccount.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[showHiddenAccount addTarget:self 
							  action:@selector(showHiddenAccounts:)
					forControlEvents:UIControlEventTouchDown];

		
		UIButton *clearStoredData = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearStoredData setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
		[clearStoredData setTitle:NSLocalizedString(@"ClearStoredBalanceInformation", nil) forState:UIControlStateNormal];
		clearStoredData.frame = CGRectMake(xOffset, 60, footerView.bounds.size.width - (xOffset*2), 40.0);
		clearStoredData.autoresizingMask = showHiddenAccount.autoresizingMask;
        
		[clearStoredData addTarget:self 
							  action:@selector(clearStoredData:)
					forControlEvents:UIControlEventTouchDown];
		
		[footerView addSubview:showHiddenAccount];
		[footerView addSubview:clearStoredData];
        
        showHiddenAccount.titleLabel.font = clearStoredData.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        showHiddenAccount.titleLabel.shadowColor = clearStoredData.titleLabel.shadowColor = [UIColor blackColor];
        showHiddenAccount.titleLabel.shadowOffset = clearStoredData.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
	}
	
	return footerView;
}

// Need to call to pad the footer height otherwise the footer collapses
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section 
{
    return section == 0 ? 110 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return (indexPath.section == 0 && indexPath.row == 2) ? 110 : 44;
}

#pragma mark - Key lock delegate methods

- (void)validateKeyCombination:(NSArray *)keyCombination sender:(id)sender
{
	int comboCount = [keyCombination count];
	
	if (comboCount > 3) {
		[MittSaldoSettings setKeyLockCombination:keyCombination];
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[self.appLockSwitch setOn:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		[MittSaldoSettings setKeyLockCombination:nil];
		[(BSKeyLock*)sender deemKeyCombinationInvalid];
		[self.appLockSwitch setOn:NO];
	}
}

#pragma mark - Switch delegate methods

- (IBAction)tactivoappLockSwitchChanged:(id)sender
{
	if ([(UISwitch *)sender isOn]) {
        
#ifdef TACTIVO
        // OPEN TACTIVO!
        PBBiometryUser* user = [[[PBBiometryUser alloc] initWithUserId:1] autorelease];
        PBManageFingersController* manageFingersController = [[[PBManageFingersController alloc] initWithDatabase:[PBReferenceDatabase sharedClass] andUser:user] autorelease];
   
        [self.navigationController pushViewController:manageFingersController animated:YES];
        [MittSaldoSettings setIsTactivoEnabled:YES];
        
		// Set the switch back to NO, we want the user to set a key for it to be active
		[(UISwitch*)sender setOn:NO];
#else
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Tactivo is not available in this build"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [(UISwitch *)sender setOn:NO animated:YES];
#endif
	}
	else {
		[MittSaldoSettings setIsTactivoEnabled:NO];
	}    
}

- (IBAction)appLockSwitchChanged:(id)sender
{
	if ([(UISwitch *)sender isOn]) {
		KeyLockViewController *keyLock = [[KeyLockViewController alloc] initWithNibName:nil bundle:nil headerText:@"Ange ditt mönster"];
		keyLock.appDelegate = self;
		[self.navigationController pushViewController:keyLock animated:YES];
		[keyLock release];
		
		// Set the switch back to NO, we want the user to set a key for it to be active
		[(UISwitch *)sender setOn:NO];
	}
	else {
		// Clear the key lock combo
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[MittSaldoSettings setKeyLockCombination:nil];
	}
}

- (IBAction)updateOnStartSwitchChanged:(id)sender
{
    [MittSaldoSettings setIsUpdateOnStartEnabled:[(UISwitch *)sender isOn]];
}

#pragma mark - Button delegate method

- (void)showHiddenAccounts:(id)sender
{
    NSManagedObjectContext *moc = [NSManagedObjectContext sharedContext];
	NSArray *accounts = [moc searchObjectsInContext:@"MSBankAccount" 
                                          predicate:[NSPredicate predicateWithFormat:@"displayAccount == 0"] 
                                            sortKey:@"accountid" 
                                      sortAscending:NO];
    
	int accountsCount = [accounts count];
	
	for (int i = 0; i < accountsCount; i++) {
		MSBankAccount *a = [accounts objectAtIndex:i];
		a.displayAccount = [NSNumber numberWithInt:1];
	}
	
	NSError * error;
	// Store the objects
	if (![moc save:&error]) {
        [moc rollback];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:[error localizedDescription]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}

- (void)clearStoredData:(id)sender
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

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// tag 1 = clear balance information
	if (alertView.tag == 1 && buttonIndex == 1) {
		
        NSManagedObjectContext *moc = [NSManagedObjectContext sharedContext];
        
        // Get all accounts
		NSMutableArray* mutableFetchResults = [moc getObjectsFromContext:@"MSBankAccount" 
                                                                 sortKey:@"accountid" 
                                                           sortAscending:NO];
		
		// Delete all accounts
		for (int i = 0; i < [mutableFetchResults count]; i++) {
			[moc deleteObject:[mutableFetchResults objectAtIndex:i]];
		}
		
		// Update the data model effectivly removing the objects we removed above.
		NSError *error;
		if (![moc save:&error]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
															message:[error localizedDescription]
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"SettingsView";
}

@end
