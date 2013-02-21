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

#import "BankSettingsViewController.h"
#import "UITextInputCell.h"
#import "MittSaldoSettings.h"
#import "BSKeyboardAwareTableView.h"
#import "MSConfiguredBank+Helper.h"
#import "NSString+Helper.h"
#import "MBProgressHUD.h"
#import "MSLServicesFactory.h"
#import "MSLServiceProxyBase.h"

static int kRemoveBankConfirmationAlertTag = 10;

@interface BankSettingsViewController ()
- (BOOL)isBankConfigured;
- (void)addNavigationBar;
- (NSString *)settingsValueForKey:(NSString *)key;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) NSObject<MSLServiceDescriptionProtocol> *serviceDescription;
@property (nonatomic, retain) MSConfiguredBank *configuredBank;
@end

@implementation BankSettingsViewController

- (void)dealloc
{
    [_serviceDescription release];
    [_saveButton release];
    [_configuredBank release];
    [_tableView release];
    [super dealloc];
}

+ (id)bankSettingsTableWithBankIdentifier:(NSString *)identifier
{
     return [[[BankSettingsViewController alloc] initWithBankIdentifier:identifier] autorelease];
}

+ (id)bankSettingsTableWithConfiguredBank:(MSConfiguredBank *)configuredBank
{
    return [[[BankSettingsViewController alloc] initWithConfiguredBank:configuredBank] autorelease];
}

- (id)initWithBankIdentifier:(NSString *)identifier
{
    if ((self = [super init])) {
        self.serviceDescription = [MSLServicesFactory descriptionForServiceWithIdentifier:identifier];
    }
    
    return self;
}

- (id)initWithConfiguredBank:(MSConfiguredBank *)configuredBank
{
    if ((self = [super init])) {
        self.configuredBank = configuredBank;
        self.serviceDescription = [MSLServicesFactory descriptionForServiceWithIdentifier:configuredBank.bankIdentifier];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.keyboardDelegate = self;
    
    if (!self.configuredBank) {
        [self addNavigationBar];        
    }
    else {
        self.title = self.configuredBank.name;
        self.saveButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveBank:)] autorelease];
        self.navigationItem.rightBarButtonItem = self.saveButton;
        
        UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
        
        UIImage *image = [UIImage imageNamed:@"button_red.png"];
        float w = image.size.width / 2, h = image.size.height / 2;
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setTitle:NSLocalizedString(@"Erase", nil) forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(removeBank:) forControlEvents:UIControlEventTouchUpInside];
        
        int xOffset = 10;
        if(IDIOM == IPAD) {
            xOffset = 45;
        }
        
        deleteButton.frame = CGRectMake(xOffset, 0, bgView.frame.size.width - (2*xOffset), bgView.frame.size.height);
        
        deleteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [bgView addSubview:deleteButton];
        self.tableView.tableFooterView = bgView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.saveButton.enabled = [self isBankConfigured];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.configuredBank) {
        NSError * error;
        // Store the objects
        if (![[NSManagedObjectContext sharedContext] save:&error]) {
            // Log the error.
            NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
            
#pragma mark - Private methods

- (NSString *)settingsValueForKey:(NSString *)key
{
    NSIndexPath *path = nil;
    if ([key isEqualToString:@"name"]) {
        path = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if ([key isEqualToString:@"ssn"]) {
        path = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    else if ([key isEqualToString:@"pwd"]) {
        path = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    if (path) {
        if ([[self.tableView cellForRowAtIndexPath:path] isKindOfClass:[UITextInputCell class]]) {
            return ((UITextInputCell *)[self.tableView cellForRowAtIndexPath:path]).textField.text;            
        }
    }
    
    return nil;
}

- (BOOL)isBankConfigured
{
    if (![NSString stringIsNullEmpty:[self settingsValueForKey:@"name"]] && 
        ![NSString stringIsNullEmpty:[self settingsValueForKey:@"ssn"]] && 
        ![NSString stringIsNullEmpty:[self settingsValueForKey:@"pwd"]]) {
        return YES;
    }
    
    return NO;
}

- (void)addNavigationBar
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bar];
    [bar release];
    
    self.navigationItem.title = self.serviceDescription.serviceName;
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(dismissView:)] autorelease];
    self.saveButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(addNewBank:)] autorelease];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [bar pushNavigationItem:self.navigationItem animated:NO];
    
    CGRect tableRect = CGRectOffset(self.tableView.frame, 0, 44);
    tableRect.size.height -= 44;
    self.tableView.frame = tableRect;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return !self.configuredBank ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.configuredBank && self.configuredBank.bookmarkURL) {
        return 4;
    }
    else if (!self.configuredBank && section == 1) {
        return 1;
    }
    
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[UITextInputCell class]]) {
        [((UITextInputCell *)cell).textField becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.configuredBank && indexPath.section == 1 && indexPath.row == 0) {
        NSString *localizationKey = [NSString stringWithFormat:@"%@-AddBankInfo", self.serviceDescription.serviceIdentifier];
        NSString *helpText = NSLocalizedString(localizationKey, nil);
        
        int width = self.tableView.bounds.size.width - 40;
        return [helpText sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height + 20;
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    UITableViewCell *cell = nil;

    if (!self.configuredBank && indexPath.section == 1 && indexPath.row == 0) {
        UITableViewCell *helpCell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"HelpCell"];
        if (helpCell == nil) {
            helpCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HelpCell"] autorelease];
        }
        
        NSString *localizationKey = [NSString stringWithFormat:@"%@-AddBankInfo", self.serviceDescription.serviceIdentifier];
        NSString *helpText = NSLocalizedString(localizationKey, nil);
        helpCell.textLabel.text = helpText;
        helpCell.textLabel.font = [UIFont systemFontOfSize:14];
        helpCell.textLabel.numberOfLines = 0;
        
        cell = helpCell;
    }
    else if (indexPath.row < 3) {
        static NSString *cellIdentifier = @"inputcell";
        UITextInputCell *inputCell = (UITextInputCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (inputCell == nil) {
            inputCell = [[[UITextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if (indexPath.row == 0) {
            inputCell.textLabel.text = NSLocalizedString(@"Name", nil);
            inputCell.textField.placeholder = [NSString stringWithFormat:@"%@ (eller vad du vill...)", self.serviceDescription.serviceName];
            inputCell.textField.secureTextEntry = NO;
            inputCell.textField.keyboardType = UIKeyboardTypeDefault;
            inputCell.textField.settingsKey = @"name";
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.name;
            }
        }
        else if (indexPath.row == 1) {
            inputCell.textLabel.text = self.serviceDescription.usernameCaption;
            inputCell.textField.secureTextEntry = NO;
            inputCell.textField.keyboardType = self.serviceDescription.isNumericOnlyUsername ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
            inputCell.textField.settingsKey = @"ssn";
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.ssn;
            }
        }
        else if (indexPath.row == 2) {
            inputCell.textLabel.text = self.serviceDescription.passwordCaption;
            inputCell.textField.secureTextEntry = YES;
            inputCell.textField.keyboardType = UIKeyboardTypeDefault;
            inputCell.textField.settingsKey = @"pwd";
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.password;
            }
        }
        
        inputCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputCell.textField.delegate = self;
        cell = inputCell;
    }
    else if (indexPath.row == 3) {
        UITableViewCell *buttonCell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"];
        if (buttonCell == nil) {
            buttonCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BookmarkCell"] autorelease];
        }
        
        buttonCell.textLabel.text = NSLocalizedString(@"Bookmark", nil);
        
        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Load our image normally.
        UIImage *image = [UIImage imageNamed:@"button_red.png"];
        float w = image.size.width / 2, h = image.size.height / 2;
        
        [removeBtn setBackgroundImage:[image stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateNormal];
        [removeBtn setTitle:NSLocalizedString(@"Erase", nil) forState:UIControlStateNormal];
        removeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        removeBtn.frame = CGRectMake(0, 0, 63, 33);
        [removeBtn addTarget:self action:@selector(removeBookmark:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonCell setAccessoryView:removeBtn];
        cell = buttonCell;
    }
    
    cell.backgroundColor = RGB(237, 242, 244);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)verifyBankLogin:(NSString *)bankIdentifier
{
    // Make sure the login works!
    MSLServiceProxyBase *serviceProxy = [self.serviceDescription serviceProxyWithUsername:[self settingsValueForKey:@"ssn"] andPassword:[self settingsValueForKey:@"pwd"]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Verifierar inloggningsuppgifter";
    
    [serviceProxy performLoginWithSuccessBlock:^{
        
        [hud hide:YES];
        
        BOOL isNewBank = NO;
        
        if (!self.configuredBank) {
            self.configuredBank = [MSConfiguredBank insertNewBankWithName:[self settingsValueForKey:@"name"] bankIdentifier:self.serviceDescription.serviceIdentifier];
            
            isNewBank = YES;
        }
        
        self.configuredBank.ssn = [self settingsValueForKey:@"ssn"];
        self.configuredBank.password = [self settingsValueForKey:@"pwd"];
        [NSManagedObjectContext saveAndAlertOnError];
        
        if (self.delegate && isNewBank) {
            [self.delegate bankSettingsViewController:self didAddBank:self.configuredBank];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error, NSString *errorMessage) {
        
        [hud hide:YES];

        NSString *alertMessage = nil;
        NSString *title = nil;

        if (error) {
            if (error.code == NSURLErrorTimedOut) {
                title = @"Timeout";
                alertMessage = @"Banken har inte svarat på anrop. Det kan bero på att deras tjänst är ur funktion eller att din anslutning inte fungerar optimalt.";
            }
            else {
                title = @"Anslutningsproblem";
                alertMessage = [error localizedDescription];    
            }
        }
        else if ([errorMessage isEqualToString:@"BankLoginDeniedAlert"]) {
            title = NSLocalizedString(@"AddBankLoginAlertTitle", nil);
            alertMessage = NSLocalizedString(@"AddBankLoginAlertMessage", nil);
        }
        else if (errorMessage) {
            alertMessage = NSLocalizedString(errorMessage, errorMessage);
        
        }
 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
                                                        message:alertMessage 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }];
}

#pragma mark - Actions

- (IBAction)dismissView:(id)sender
{
    [self.view.window.rootViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)addNewBank:(id)sender
{
    [self.tableView.textField resignFirstResponder];
    
    if ([self isBankConfigured]) {
        [self verifyBankLogin:self.serviceDescription.serviceIdentifier];
    }
}

- (IBAction)saveBank:(id)sender
{
    [self.tableView.textField resignFirstResponder];
    
    if ([self isBankConfigured]) {
        self.configuredBank.name = [self settingsValueForKey:@"name"];
        
        // If username / ssn changed we re-verify the new credentials
        if (![self.configuredBank.ssn isEqualToString:[self settingsValueForKey:@"ssn"]] ||
            ![self.configuredBank.password isEqualToString:[self settingsValueForKey:@"pwd"]]) {
            [self verifyBankLogin:self.configuredBank.bankIdentifier];
        }
        else {
            [NSManagedObjectContext saveAndAlertOnError];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)removeBookmark:(id)sender
{
    self.configuredBank.bookmarkURL = nil;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (IBAction)removeBank:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Är du säker?" 
                                                    message:[NSString stringWithFormat:@"Vill du verkligen ta bort %@", self.configuredBank.name]
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    
    alert.tag = kRemoveBankConfirmationAlertTag;
    [alert show];
    [alert release];
}

#pragma mark - Alert view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kRemoveBankConfirmationAlertTag && buttonIndex == 1) {
        [MittSaldoSettings removeConfiguredBank:self.configuredBank];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Text Field delegate methods

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
    self.tableView.textField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.saveButton.enabled = [self isBankConfigured];
    return YES;
}

// When the user is done editing we save the setting
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// Cast the textbox to our custom class and save the input
	BSSettingsTextField *settingsField = (BSSettingsTextField *)textField;
    
    self.tableView.textField = nil;
	
    if ([settingsField.text length] > 0) {
        NSString *validationError = nil;
        if ([settingsField.settingsKey isEqualToString:@"ssn"]) {
            [self.serviceDescription isValidUsernameForService:settingsField.text validationMessage:&validationError];
        }
        else if([settingsField.settingsKey isEqualToString:@"pwd"]) {
            [self.serviceDescription isValidPasswordForService:settingsField.text validationMessage:&validationError];
        }
        
        if (validationError) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InputErrorQuestion", nil)
                                                            message:validationError
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)   
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }

    self.saveButton.enabled = [self isBankConfigured];
}

#pragma mark - Accessors

- (NSBundle *)nibBundle
{
    return [NSBundle mainBundle];
}

- (NSString *)nibName
{
    return @"BankSettings";
}

@end
