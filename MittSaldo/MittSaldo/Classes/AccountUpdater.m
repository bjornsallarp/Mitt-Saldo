//
//  Created by Björn Sållarp on 2010-05-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AccountUpdater.h"
#import "MSConfiguredBank+Helper.h"
#import "MSBankAccount.h"
#import "NSManagedObjectContext+MSHelper.h"
#import "MSLParsedAccount.h"
#import "MSLServiceProxyBase.h"
#import "MSLServicesFactory.h"

#define MAX_SIMULTANIOUS_UPDATES 4

@interface AccountUpdater ()
@property (nonatomic, retain) NSMutableArray *updateQueue;
@property (nonatomic, retain) NSMutableDictionary *runningBankUpdates;
@end

@implementation AccountUpdater

- (void)dealloc
{	
    [_runningBankUpdates release];
    [_updateQueue release];
    [_successBlock release];
    [_failureBlock release];
	[super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.updateQueue = [NSMutableArray array];
        self.runningBankUpdates = [NSMutableDictionary dictionary];
    }
                            
    return self;
}

+ (void)persistAccountBalance:(MSConfiguredBank *)service accounts:(NSArray *)parsedAccounts
{
    for (MSLParsedAccount *parsedAccount in parsedAccounts) {
        // Check to see if the account already exist in our database
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(configuredbank == %@) && (accountid == %@)", service, parsedAccount.accountId];
        MSBankAccount *account = (MSBankAccount *)[[[NSManagedObjectContext sharedContext] searchObjectsInContext:@"MSBankAccount"
                                                                                                        predicate:predicate
                                                                                                          sortKey:@"accountid"
                                                                                                    sortAscending:YES] lastObject];
        if (!account) {
            account = (MSBankAccount *)[NSManagedObjectContext insertEntityForName:@"MSBankAccount"];
        }
        
        NSString *accountName = [parsedAccount.accountName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
        accountName = [accountName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        // If the account name changed we update and also change the user set account name.
        if (![accountName isEqualToString:account.accountName]) {
            account.displayName = accountName;
        }
        
        account.accountName = accountName;
        account.configuredbank = service;
        account.amount = parsedAccount.amount;
        account.bankIdentifier = service.bankIdentifier;
        account.accountid = parsedAccount.accountId;
        account.updatedDate = [NSDate date];
        account.availableAmount = parsedAccount.availableAmount;
    }

    [NSManagedObjectContext saveAndAlertOnError];
}

- (void)reportProgess:(MSConfiguredBank *)bank successful:(BOOL)successful error:(NSError *)error message:(NSString *)message
{
    [self.updateQueue removeObject:bank];
    [self.runningBankUpdates removeObjectForKey:bank.guid];
    
    [self proccessQueue];
    
    if (!successful && self.failureBlock) {
        self.failureBlock(bank, error, message);
    }
    else if (successful && self.successBlock) {
        self.successBlock(bank);
    }
}

- (void)proccessQueue
{
    for (MSConfiguredBank *service in self.updateQueue) {
        
        if ([self.runningBankUpdates.allKeys count] == MAX_SIMULTANIOUS_UPDATES) {
            break;
        }
        
        if ([self.runningBankUpdates valueForKey:service.guid]) {
            continue;
        }
        
        __block MSLServiceProxyBase *login = [MSLServicesFactory proxyForServiceWithIdentifier:service.bankIdentifier];
        login.username = service.ssn;
        login.password = service.password;
        
        [self.runningBankUpdates setValue:login forKey:service.guid];
        
        [login performLoginWithSuccessBlock:^{
            [login fetchAccountBalance:^(NSArray *accounts) {
                
                [AccountUpdater persistAccountBalance:service accounts:accounts];
                [self reportProgess:service successful:YES error:nil message:nil];
                
            } failure:^(NSError *error, NSString *errorMessage) {
                
                debug_NSLog(@"Account update, error: %@", [error localizedDescription]);
                debug_NSLog(@"Account update failed: %@. %@", errorMessage, service.bankIdentifier);
                [self reportProgess:service successful:NO error:error message:errorMessage];
            }];
            
        } failure:^(NSError *error, NSString *errorMessage) {
            
            debug_NSLog(@"Login failed: %@. %@", errorMessage, service.bankIdentifier);
            [self reportProgess:service successful:NO error:error message:errorMessage];
        }];
    }
}

- (void)enqueueBankForUpdate:(MSConfiguredBank *)bank
{
    if (![self isUpdatingBankWithGuid:bank.guid]) {
        [self.updateQueue addObject:bank];
        [self proccessQueue];
    }
}

- (BOOL)isUpdatingBankWithGuid:(NSString *)guid
{
    for (MSConfiguredBank *bank in self.updateQueue) {
        if ([bank.guid isEqualToString:guid])
            return YES;
    }

    return NO;
}

- (NSArray *)banksBeingUpdated
{    
    return [NSArray arrayWithArray:self.updateQueue];
}

#pragma mark - Accessors

- (BOOL)isUpdating
{
    return [self.updateQueue count] > 0;
}

@end
