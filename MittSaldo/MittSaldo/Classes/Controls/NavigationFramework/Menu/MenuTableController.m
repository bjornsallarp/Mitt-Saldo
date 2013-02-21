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

#import <QuartzCore/QuartzCore.h>
#import "MSLServicesFactory.h"
#import "MenuTableController.h"
#import "MenuTableCell.h"
#import "MenuTableViewHeader.h"
#import "SettingsView.h"
#import "MittSaldoSettings.h"
#import "MSConfiguredBank+Helper.h"
#import "WebBankViewController.h"
#import "AboutMittSaldoViewController.h"
#import "ErrorReportingViewController.h"
#import "SmartbudgetViewController.h"
#import "InAppPurchaseViewController.h"
#import "CardDetailsBaseViewController.h"

@interface MenuTableController ()

- (void)openMenuItemWithIdentifier:(NSString *)identifier;
@property (nonatomic, retain) NSArray *menuItems;

@end

@implementation MenuTableController

- (void)dealloc
{
    [_navigationController release];
    [_accountBalanceViewController release];
    [_menuItems release];
    
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"MS-NavigateTo" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self openMenuItemWithIdentifier:[note.userInfo valueForKey:@"view"]];
        }];
    }
    
    return self;
}

- (void)openMenuItemWithIdentifier:(NSString *)identifier
{
    if (!identifier)
        return;
    
    if ([[identifier lowercaseString] isEqualToString:@"errorreporting"]) {
        [self.navigationController pushRootViewController:[ErrorReportingViewController controller] animated:YES];
    }
}

- (void)reloadDataForTable:(UITableView *)table
{
    table.backgroundColor = RGB(50, 57, 74);
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadMenuItems];
    [table reloadData];
}

- (void)loadMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    MenuTableRow *accountsRow = [MenuTableRow rowWithTitle:@"Mina konton" iconImageName:@"bank.png" rowSelectedActionHandler:^{
        if ([[self.navigationController.navigationController viewControllers] objectAtIndex:0] != self.accountBalanceViewController) {
            [self.navigationController pushRootViewController:self.accountBalanceViewController animated:YES];
        }
        else if (self.navigationController.isMenuOpen) {
            [self.navigationController toggleMenu:self];
        }
    }];

    MenuTableSection *accountsSection = [MenuTableSection section];
    [accountsSection.rows addObject:accountsRow];
    [menuItems addObject:accountsSection];
    

    MenuTableSection *banksSection = [MenuTableSection section];
    banksSection.title = @"BANKER";
    
    MenuTableSection *cardsSection = [MenuTableSection section];
    cardsSection.title = @"KORT";
    
    NSArray *configuredServices = [MittSaldoSettings configuredBanks];
    for (int i = 0, count = [configuredServices count]; i < count; i++) {
        MSConfiguredBank *service = [configuredServices objectAtIndex:i]; 
        id<MSLServiceDescriptionProtocol> serviceDescription = [MSLServicesFactory descriptionForServiceWithIdentifier:service.bankIdentifier];
        
        MenuTableRow *sectionRow = [[[MenuTableRow alloc] init] autorelease];
        sectionRow.title = service.name;
        
        if ([serviceDescription isBank]) {
            sectionRow.rowSelectedActionHandler = ^{
                [self.navigationController pushRootViewController:[WebBankViewController controllerForBank:service] animated:YES];
            };
            
            [banksSection.rows addObject:sectionRow];
        }
        else if ([serviceDescription isCard]) {
            sectionRow.rowSelectedActionHandler = ^{
                [self.navigationController pushRootViewController:[CardDetailsBaseViewController controllerForCard:service] animated:YES];                
            };
            
            [cardsSection.rows addObject:sectionRow];
        }
    }
    
    if ([banksSection.rows count] > 0) {
        [menuItems addObject:banksSection];
    }
    
    if ([cardsSection.rows count] > 0) {
        [menuItems addObject:cardsSection];
    }
    
    
    MenuTableSection *miscSection = [MenuTableSection section];
    miscSection.title = @"ÖVRIGT";
    
    MenuTableRow *settingsRow = [MenuTableRow rowWithTitle:@"Inställningar" iconImageName:@"cog_01.png" rowSelectedActionHandler:^{
        [self.navigationController pushRootViewController:[SettingsView controller] animated:YES];
    }];
    [miscSection.rows addObject:settingsRow];
    
    MenuTableRow *errorReportingRow = [MenuTableRow rowWithTitle:@"Felrapportera / tyck till" iconImageName:@"speech_bubble_transparent.png" rowSelectedActionHandler:^{
        [self.navigationController pushRootViewController:[ErrorReportingViewController controller] animated:YES];
    }];
    [miscSection.rows addObject:errorReportingRow];
    
    MenuTableRow *inAppPurchaseRow = [MenuTableRow rowWithTitle:@"Köp Mitt Saldo" iconImageName:@"credit_card.png" rowSelectedActionHandler:^{
        [self.navigationController toggleMenu:self];
        [self.navigationController.view.window.rootViewController presentModalViewController:[InAppPurchaseViewController controller] animated:YES];
    }];
    [miscSection.rows addObject:inAppPurchaseRow];
    
    MenuTableRow *aboutRow = [MenuTableRow rowWithTitle:@"Om Mitt Saldo" iconImageName:@"lightbulb.png" rowSelectedActionHandler:^{
        [self.navigationController pushRootViewController:[AboutMittSaldoViewController controller] animated:YES];
    }];
    [miscSection.rows addObject:aboutRow];
    
    MenuTableRow *smartBudgetRow = [MenuTableRow rowWithTitle:@"Smartbudget" iconImageName:@"icon-piggy_bank.png" rowSelectedActionHandler:^{
        [self.navigationController pushRootViewController:[SmartbudgetViewController controller] animated:YES];
    }];
    [miscSection.rows addObject:smartBudgetRow];
    
    [menuItems addObject:miscSection];
    self.menuItems = menuItems;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableSection *section = [self.menuItems objectAtIndex:indexPath.section];
    MenuTableRow *row = [section.rows objectAtIndex:indexPath.row];
    
    if (row.rowSelectedActionHandler) {
        row.rowSelectedActionHandler();
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MenuTableSection *menuSection = [self.menuItems objectAtIndex:section];
    return [menuSection.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"menucell";
    
    MenuTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[MenuTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
    MenuTableSection *section = [self.menuItems objectAtIndex:indexPath.section];
    MenuTableRow *row = [section.rows objectAtIndex:indexPath.row];
    
    cell.title = row.title;
    
    if (row.iconImageName) {
        cell.imageView.image = [UIImage imageNamed:row.iconImageName];
    }
    else {
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    MenuTableSection *menuSection = [self.menuItems objectAtIndex:section];
    return menuSection.title ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MenuTableViewHeader *header = nil;
    
    MenuTableSection *menuSection = [self.menuItems objectAtIndex:section];
    if (menuSection.title) {
        header = [[[MenuTableViewHeader alloc] initWithFrame:CGRectZero] autorelease];
        header.title = menuSection.title;
    }
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.menuItems count];
}

@end

@implementation MenuTableRow
@synthesize title = _title;
@synthesize iconImageName = _iconImageName;
@synthesize rowSelectedActionHandler = _rowSelectedActionHandler;

- (void)dealloc
{
    [_title release];
    [_iconImageName release];
    [_rowSelectedActionHandler release];
    [super dealloc];
}

- (id)initWithTitle:(NSString *)title iconImageName:(NSString *)iconImageName rowSelectedActionHandler:(void (^)(void))actionHandler
{
    if ((self = [super init])) {
        self.title = title;
        self.iconImageName = iconImageName;
        self.rowSelectedActionHandler = actionHandler;
    }
    
    return self;
}

+ (MenuTableRow *)rowWithTitle:(NSString *)title iconImageName:(NSString *)iconImageName rowSelectedActionHandler:(void (^)(void))actionHandler
{
    return [[[self alloc] initWithTitle:title iconImageName:iconImageName rowSelectedActionHandler:actionHandler] autorelease];
}

@end

@implementation MenuTableSection
@synthesize title = _title;
@synthesize rows = _rows;

- (void)dealloc
{
    [_title release];
    [_rows release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.rows = [NSMutableArray array];
    }
    
    return self;
}

+ (MenuTableSection *)section
{
    return [[[MenuTableSection alloc] init] autorelease];
}

@end
