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

#import "MSUpgradeV1ToV2.h"
#import "MittSaldoSettings.h"
#import "MSConfiguredBank+Helper.h"
#import "MSBankAccount.h"
#import "Keychain.h"

@implementation MSUpgradeV1ToV2

- (NSArray *)configuredBanks
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSMutableArray *configuredBanks = [NSMutableArray array];	
	NSArray *allBanks = [NSArray arrayWithObjects:@"Handelsbanken", @"ICA", @"Ikano", @"Länsförsäkringar", @"Nordea", @"SEB", @"Swedbank", nil];
	
	for (NSString *bankIdentifier in allBanks) {
		if ([settings objectForKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]] != nil && 
            [settings objectForKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]] != nil) {
			[configuredBanks addObject:bankIdentifier];
		}
	}
    
	return configuredBanks;
}

- (BOOL)upgrade
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
 
    if ([settings valueForKey:@"KeyLockCombo"]) {
        [Keychain setObject:[settings valueForKey:@"KeyLockCombo"] forKey:@"KeyLockCombo"];
        [settings setValue:nil forKey:@"KeyLockCombo"];
    }
    
    NSArray *configuredBanks = [self configuredBanks];
    
    for (NSString *bankIdentifier in configuredBanks) {
        MSConfiguredBank *bank = [MSConfiguredBank insertNewBankWithName:bankIdentifier bankIdentifier:bankIdentifier];

        bank.ssn = [settings objectForKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]];
        bank.password = [settings objectForKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]];
        
        NSString *bookmarkString = [settings valueForKey:[NSString stringWithFormat:@"%@Bookmark", bankIdentifier]];
        if (bookmarkString) {
            bank.bookmarkURL = [NSURL URLWithString:bookmarkString];
        }
        
        
        NSMutableArray* mutableFetchResults = [[NSManagedObjectContext sharedContext] searchObjectsInContext:@"MSBankAccount" 
                                                                           predicate:[NSPredicate predicateWithFormat:@"(bankIdentifier == %@)", bankIdentifier] 
                                                                             sortKey:@"accountid" 
                                                                       sortAscending:YES];
        
        for (MSBankAccount *account in mutableFetchResults) {
            [bank addAccountsObject:account];
        }
        
        [settings setValue:nil forKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]];
        [settings setValue:nil forKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]];
        [settings setValue:nil forKey:[NSString stringWithFormat:@"%@Bookmark", bankIdentifier]];
        [settings synchronize];
    }
    
    NSError * error;

    return [[NSManagedObjectContext sharedContext] save:&error];
}

@end
