//
//  Created by Björn Sållarp on 2010-07-24.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//


#import "MittSaldoSettings.h"
#import "MSConfiguredBank+Helper.h"
#import "Keychain.h"

#ifdef TACTIVO
#import "PBReferenceDatabase.h"
#endif

static NSString *kKeyLockFailedAttemptsKey = @"KeyLockFailedAttempts";
static NSString *kKeyLockComboKey = @"KeyLockCombo";

@implementation MittSaldoSettings


+ (BOOL)isTactivoLockActive
{
#ifdef TACTIVO
    if ([MittSaldoSettings isTactivoEnabled] && [[[PBReferenceDatabase sharedClass] getEnrolledFingers] count] > 0) {
        return YES;
    }
#endif

    return NO;
}

+ (BOOL)isTactivoEnabled
{
#ifdef TACTIVO
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"isTactivoEnabled"] boolValue];
    
#endif
    
    return NO;
}

+ (void)setIsTactivoEnabled:(BOOL)isEnabled
{
#ifdef TACTIVO
    [[NSUserDefaults standardUserDefaults] setValue:@(isEnabled) forKey:@"isTactivoEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}


+ (NSArray *)configuredBanks
{
    return [[NSManagedObjectContext sharedContext] getObjectsFromContext:@"MSConfiguredBank" sortKey:@"bankIdentifier" sortAscending:YES];
}

+ (void)resetAllPersonalInformation
{
    [Keychain removeValueForKey:kKeyLockComboKey];
    [Keychain removeValueForKey:kKeyLockFailedAttemptsKey];
    
	// Loop through supported banks and clear settings
    NSArray *services = [self configuredBanks];
    
    for (int i = 0, count = [services count]; i < count; i++) {
        MSConfiguredBank *bank = [services objectAtIndex:i];
        bank.password = nil;
        bank.ssn = nil;
        [[NSManagedObjectContext sharedContext] deleteObject:bank];
    }
    
    [NSManagedObjectContext saveAndAlertOnError];
}

+ (void)removeConfiguredBank:(MSConfiguredBank *)bank
{
    bank.password = nil;
    bank.ssn = nil;
    [[NSManagedObjectContext sharedContext] deleteObject:bank];
    [NSManagedObjectContext saveAndAlertOnError];
}

+ (void)setAlreadyRatedApp
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:@1 forKey:@"AppRated"];
	[settings synchronize];
}

+ (BOOL)isAppRated
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSNumber *rated = [settings valueForKey:@"AppRated"];

	return (rated != nil) ? [rated intValue] == 1 : NO;
}

+ (BOOL)hasPaidForApp
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSNumber *rated = [settings valueForKey:@"AppPaid"];
    
	return (rated != nil) ? [rated intValue] == 1 : NO;
}

+ (void)setKeyLockFailedAttempts:(int)attempts
{
	[Keychain setObject:@(attempts) forKey:kKeyLockFailedAttemptsKey];
}

+ (NSNumber *)getKeyLockFailedAttempts
{
    NSNumber *failedAttempts = [Keychain objectForKey:kKeyLockFailedAttemptsKey];
    return failedAttempts ? failedAttempts : @0;
}

+ (NSArray *)getKeyLockCombination
{
    return [Keychain objectForKey:kKeyLockComboKey];
}

+ (void)setKeyLockCombination:(NSArray *)combo
{
    [Keychain setObject:combo forKey:kKeyLockComboKey];
}

+ (BOOL)isKeyLockActive
{
	return [self getKeyLockCombination] != nil;
}

+ (BOOL)isUpdateOnStartEnabled
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"updateOnStart"] boolValue];
}

+ (void)setIsUpdateOnStartEnabled:(BOOL)isEnabled
{
    [[NSUserDefaults standardUserDefaults] setValue:@(isEnabled) forKey:@"updateOnStart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setApplicationDidEnterBackground:(NSDate *)date
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:date forKey:@"enteredBackgroundTime"];
	[settings synchronize];
}

+ (NSDate *)getApplicationDidEnterBackground
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	return [settings valueForKey:@"enteredBackgroundTime"];
}

+ (int)multitaskingTimeout
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if ([settings valueForKey:@"multitaskingTimeout"] == nil) {
		return 30;
	}
	
	return [[settings valueForKey:@"multitaskingTimeout"] intValue];
}

@end
