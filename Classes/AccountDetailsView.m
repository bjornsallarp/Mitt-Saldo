//
//  Created by Björn Sållarp on 2010-05-16.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AccountDetailsView.h"
#import "MittSaldoAppDelegate.h"
#import "UIAlertView+Helper.h"
#import "KundoViewController.h"

@implementation AccountDetailsView
@synthesize managedObjectContext, accountToEdit;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil account:(BankAccount*)account
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.accountToEdit = account;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.managedObjectContext = ((MittSaldoAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

#pragma mark - Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int rows = 0;
	
	switch (section) {
		case 0:
			rows = 2;
			break;
		default:
			break;
	}
	
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	NSString *name = nil;
	
	switch (section) {
		case 0:
			name = NSLocalizedString(@"AccountSettings", nil);
			break;
		default:
			break;
	}
	
	
	return name;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *MyIdentifier = @"AccountDetailsIdentifier";
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			UITextInputCell *inputCell = (UITextInputCell*)[detailsTable dequeueReusableCellWithIdentifier:MyIdentifier];
			if (inputCell == nil) {
				inputCell = [[[UITextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
			}
			
			inputCell.textLabel.text = NSLocalizedString(@"AccountName", nil);
			inputCell.textField.text = accountToEdit.displayName;
			inputCell.textField.tag = 1;
			inputCell.textField.delegate = self;
			
			cell = inputCell;
		}
		else if (indexPath.row == 1) {
			UISwitchCell *switchCell = (UISwitchCell*)[detailsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			switchCell.textLabel.text = NSLocalizedString(@"ShowInAccountList", nil);
			[switchCell.switchControl addTarget:self action:@selector(displayAccountSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			
			switchCell.switchControl.on = accountToEdit.displayAccount.intValue > 0;
			cell = switchCell;
		}
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}



#pragma mark - Switch delegate method

- (IBAction)displayAccountSwitchChanged:(id)sender
{
	accountToEdit.displayAccount = [(UISwitch*)sender isOn] ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
		
	NSError * error;
	// Store the objects
	if (![managedObjectContext save:&error]) {
		[managedObjectContext rollback];
        
		[UIAlertView showErrorAlertViewWithTitle:nil message:[error localizedDescription] delegate:self];
		
		// Log the error.
		NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
	}
}

#pragma mark - Text Field delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// Close/hide the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if([textField.text length] > 0)
	{
		accountToEdit.displayName = textField.text;
		
		NSError * error;
		// Store the objects
		if (![managedObjectContext save:&error]) {
            [managedObjectContext rollback];
            
            [UIAlertView showErrorAlertViewWithTitle:nil message:[error localizedDescription] delegate:self];
			
			// Log the error.
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
	}	
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kErrorAlertViewTag) {
        if (buttonIndex == 1) {
            [KundoViewController presentFromViewController:self userEmail:nil userName:nil];
        }
    }
}

#pragma mark -
#pragma mark Memmory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
	[managedObjectContext release];
	[accountToEdit release];
	
	// Outlets
	[detailsTable release];
	
    [super dealloc];
}


@end
