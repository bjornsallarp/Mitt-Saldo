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

@implementation MittSaldoSettings

+ (NSArray *)supportedBanks
{
	return [NSArray arrayWithObjects:@"Handelsbanken", @"ICA", @"Ikano", @"Länsförsäkringar", @"Nordea", @"SEB", @"Swedbank", nil];
}

+ (NSString *)bankShortName:(NSString*)bankIdentifier
{
    NSString *returnValue = [NSString stringWithString:bankIdentifier];
    
    if ([bankIdentifier isEqualToString:@"Handelsbanken"]) {
        returnValue = @"SHB";
    }
    else if ([bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
        returnValue = @"LF";
    }
    else if ([bankIdentifier isEqualToString:@"Swedbank"]) {
        returnValue = @"FSB";
    }
    
    return returnValue;
}

+ (BOOL)isBankConfigured:(NSString*)bankIdentifier
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if ([settings objectForKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]] != nil && 
	   [settings objectForKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]] != nil) {		
		return YES;
	}
	
	return NO;
}

+ (void)removeCookiesForBank:(NSString*)bankIdentifier
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
	NSURL *url = [NSURL URLWithString:[settings objectForKey:[NSString stringWithFormat:@"%@Login", bankIdentifier]]];
	NSArray *cookiesForURL = [[[cookieStorage cookiesForURL:url] copy] autorelease];
	for (NSHTTPCookie *each in cookiesForURL) {
		[cookieStorage deleteCookie:each];
	}		
}


+ (void)loadStandardSettings
{
	// Store important URL's in settings.
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:@"https://mobilbank.swedbank.se/banking/swedbank/login.html" forKey:@"SwedbankLogin"];
	[settings setObject:@"https://mobilbank.swedbank.se/banking/swedbank/accounts.html" forKey:@"SwedbankAccounts"];
	[settings setObject:@"https://mobilbank.swedbank.se/banking/swedbank/newTransfer.html" forKey:@"SwedbankTransfer"];
	[settings setObject:@"https://mobil.nordea.se/banking-nordea/nordea-c3/login.html" forKey:@"NordeaLogin"];
	[settings setObject:@"https://mobil.nordea.se/banking-nordea/nordea-c3/accounts.html" forKey:@"NordeaAccounts"];
	[settings setObject:@"https://mobil.nordea.se/banking-nordea/nordea-c3/transfer.html" forKey:@"NordeaTransfer"];
	[settings setObject:@"https://mobil.icabanken.se/logga-in/" forKey:@"ICALogin"];
	[settings setObject:@"https://mobil.icabanken.se/konton/" forKey:@"ICAAccounts"];
	[settings setObject:@"https://mobil.icabanken.se/overfor/" forKey:@"ICATransfer"];
	[settings setObject:@"https://mobil.lansforsakringar.se/lf-mobile/pages/login.faces?pnr=null" forKey:@"LänsförsäkringarLogin"];
	[settings setObject:@"https://mobil.lansforsakringar.se/lf-mobile/pages/overview.faces" forKey:@"LänsförsäkringarAccounts"];
	[settings setObject:@"https://mobil.lansforsakringar.se/lf-mobile/pages/overview.faces" forKey:@"LänsförsäkringarTransfer"];
    
    [settings setObject:@"https://m.seb.se/cgi-bin/pts3/mps/1000/mps1001bm.aspx" forKey:@"SEBLogin"];
    [settings setObject:@"https://m.seb.se/cgi-bin/pts3/mps/1100/mps1101.aspx?X1=passWord" forKey:@"SEBAccounts"];
    [settings setObject:@"https://m.seb.se/cgi-bin/pts3/mps/1100/mps1104.aspx?P1=E" forKey:@"SEBTransfer"];
	
    [settings setObject:@"https://secure.ikanobank.se/MobilLogin" forKey:@"IkanoLogin"];
    [settings setObject:@"https://secure.ikanobank.se/MobilOversikt" forKey:@"IkanoAccounts"];
    [settings setObject:@"https://secure.ikanobank.se/MobilSparaOverforing" forKey:@"IkanoTransfer"];
	
	// Handelsbanken is different, their URLs change constantly.
	[settings setObject:@"https://m.handelsbanken.se" forKey:@"HandelsbankenLogin"];
	[settings setObject:@"https://m.handelsbanken.se" forKey:@"HandelsbankenAccounts"];
	[settings setObject:@"https://m.handelsbanken.se" forKey:@"HandelsbankenTransfer"];
	[settings synchronize];
	
	NSArray *configuredBanks = [self configuredBanks];
	
	// Clear cookies for our banks
	for (NSString *bankIdentifier in configuredBanks) {
		[self removeCookiesForBank:bankIdentifier];
	}
}

+ (NSArray *)configuredBanks
{
	NSMutableArray *configuredBanks = [NSMutableArray array];	
	NSArray *allBanks = [self supportedBanks];
	
	for (NSString *bankIdentifier in allBanks) {
		if ([self isBankConfigured:bankIdentifier]) {
			[configuredBanks addObject:bankIdentifier];
		}
	}
		
	return configuredBanks;
}

+ (void)resetAllPersonalInformation
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:[NSNumber numberWithInt:0] forKey:@"KeyLockFailedTries"];
	[settings setObject:nil forKey:@"KeyLockCombo"];

	// Loop through supported banks and clear settings
	for (NSString *bankIdentifier in [self supportedBanks]) {
		[settings setValue:nil forKey:[NSString stringWithFormat:@"%@_ssn_preference", bankIdentifier]];
		[settings setValue:nil forKey:[NSString stringWithFormat:@"%@_pwd_preference", bankIdentifier]];
	}

	[settings synchronize];
}

+ (void)setAlreadyRatedApp
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:[NSNumber numberWithInt:1] forKey:@"AppRated"];
	[settings synchronize];
}

+ (BOOL)isAppRated
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSNumber *rated = [settings valueForKey:@"AppRated"];	

	return (rated != nil) ? [rated intValue] == 1 : NO;
}

+ (void)setKeyLockFailedAttempts:(int)attempts
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:[NSNumber numberWithInt:attempts] forKey:@"keyLockFailedAttempts"];
	[settings synchronize];
}

+ (NSNumber *)getKeyLockFailedAttempts
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	return [settings valueForKey:@"keyLockFailedAttempts"];
}

+ (NSArray *)getKeyLockCombination
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	return [settings valueForKey:@"KeyLockCombo"];
}

+ (void)setKeyLockCombination:(NSArray*)combo
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:combo forKey:@"KeyLockCombo"];
	[settings synchronize];
}

+ (BOOL)isKeyLockActive
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	return [settings valueForKey:@"KeyLockCombo"] != nil;
}

+ (void)setApplicationDidEnterBackground:(NSDate*)date
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:date forKey:@"enteredBackgroundTime"];
	[settings synchronize];
}

+ (NSDate*)getApplicationDidEnterBackground
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

+ (BOOL)isDebugEnabled
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	return ([settings valueForKey:@"debugModeEnabled"] != nil && [[settings valueForKey:@"debugModeEnabled"] intValue] == 1);
}

+ (BOOL)isBookmarkSetForBank:(NSString *)bankIdentifier
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    id obj = [settings valueForKey:[NSString stringWithFormat:@"%@Bookmark", bankIdentifier]];
    return obj != nil;
}

@end
