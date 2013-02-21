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
#import "NSManagedObjectContext+MSHelper.h"
#import "UITextInputCell.h"
#import "UISwitchCell.h"
#import "MSBankAccount.h"

@implementation AccountDetailsView

- (void)dealloc 
{
	[_accountToEdit release];
	[_detailsTable release];
	
    [super dealloc];
}

+ (id)accountDetailsViewForAccount:(MSBankAccount *)account
{
    AccountDetailsView *detailsView = [[self alloc] initWithNibName:nil bundle:nil];
    detailsView.accountToEdit = account;
    
    return [detailsView autorelease];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title = NSLocalizedString(@"AccountSettings", nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return section == 0 ? 2 : 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *MyIdentifier = @"AccountDetailsIdentifier";
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			UITextInputCell *inputCell = (UITextInputCell*)[self.detailsTable dequeueReusableCellWithIdentifier:MyIdentifier];
			if (inputCell == nil) {
				inputCell = [[[UITextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
			}
			
			inputCell.textLabel.text = NSLocalizedString(@"AccountName", nil);
			inputCell.textField.text = self.accountToEdit.displayName ? self.accountToEdit.displayName : self.accountToEdit.accountName;
			inputCell.textField.tag = 1;
			inputCell.textField.delegate = self;
			
			cell = inputCell;
		}
		if (indexPath.row == 1) {
			UISwitchCell *switchCell = (UISwitchCell*)[self.detailsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			switchCell.textLabel.text = NSLocalizedString(@"ShowInAccountList", nil);
			[switchCell.switchControl addTarget:self action:@selector(displayAccountSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			
			switchCell.switchControl.on = self.accountToEdit.displayAccount.intValue > 0;
			cell = switchCell;
		}
	}
	
    cell.backgroundColor = RGB(237, 242, 244);
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

#pragma mark - Switch delegate method

- (IBAction)displayAccountSwitchChanged:(id)sender
{
	self.accountToEdit.displayAccount = [NSNumber numberWithBool:[(UISwitch*)sender isOn]];
	[NSManagedObjectContext saveAndAlertOnError];
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
	if ([textField.text length] > 0) {
		self.accountToEdit.displayName = textField.text;
		[NSManagedObjectContext saveAndAlertOnError];
	}	
}


#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AccountDetailsView";
}

@end
