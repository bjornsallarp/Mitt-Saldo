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

#import "AvailableBanksTableViewController.h"
#import "MSLServicesFactory.h"
#import "MittSaldoSettings.h"

@interface AvailableBanksTableViewController()
@property (nonatomic, retain) NSArray *supportedBanks;
@property (nonatomic, retain) NSArray *supportedCards;
@end

@implementation AvailableBanksTableViewController

+ (id)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)dealloc
{
    [_supportedBanks release];
    [_supportedCards release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Ny bank / kort", nil);
    
    NSArray *registeredServices = [MSLServicesFactory registeredServices];
    
    NSMutableArray *supportedBanks = [NSMutableArray array];
    NSMutableArray *supportedCards = [NSMutableArray array];
    [registeredServices enumerateObjectsUsingBlock:^(NSObject<MSLServiceDescriptionProtocol> *obj, NSUInteger idx, BOOL *stop) {
        if (obj.isBank)
            [supportedBanks addObject:obj];
        else
            [supportedCards addObject:obj];
    }];
       
    self.supportedBanks = [supportedBanks sortedArrayUsingComparator:^NSComparisonResult(NSObject<MSLServiceDescriptionProtocol> *obj1, NSObject<MSLServiceDescriptionProtocol> *obj2) {
        return [obj1.serviceName compare:obj2.serviceName];
    }];
    
    self.supportedCards = [supportedCards sortedArrayUsingComparator:^NSComparisonResult(NSObject<MSLServiceDescriptionProtocol> *obj1, NSObject<MSLServiceDescriptionProtocol> *obj2) {
        return [obj1.serviceName compare:obj2.serviceName];
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? [NSLocalizedString(@"BANKER", nil) uppercaseString] : [NSLocalizedString(@"KORT", nil) uppercaseString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? [self.supportedBanks count] : [self.supportedCards count];
}

- (NSObject<MSLServiceDescriptionProtocol> *)serviceForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.supportedBanks objectAtIndex:indexPath.row];
    }
    
    return [self.supportedCards objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSObject<MSLServiceDescriptionProtocol> *serviceDescription = [self serviceForIndexPath:indexPath];
    cell.textLabel.text = serviceDescription.serviceName;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.backgroundColor = RGB(237, 242, 244);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<MSLServiceDescriptionProtocol> *serviceDescription = [self serviceForIndexPath:indexPath];
    BankSettingsViewController *controller = [BankSettingsViewController bankSettingsTableWithBankIdentifier:serviceDescription.serviceIdentifier];
    controller.delegate = self;
    [self.view.window.rootViewController presentModalViewController:controller animated:YES];
    [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#pragma mark - Bank settings delegate method

- (void)bankSettingsViewController:(BankSettingsViewController *)controller didAddBank:(MSConfiguredBank *)bank
{
    [controller dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AvailableBanksTable";
}

- (NSBundle *)nibBundle
{
    return [NSBundle mainBundle];
}

@end
