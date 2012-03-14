//
//  Created by Björn Sållarp on 2011-02-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BankLoginFactory.h"
#import "BankLoginBase.h"
#import "LansforsakringarLogin.h"
#import "ICABankenLogin.h"
#import "HandelsbankenLogin.h"
#import "NordeaLogin.h"
#import "SEBLogin.h"
#import "SwedbankLogin.h"
#import "IkanoLogin.h"

#import "MittSaldoSettings.h"
#import "LogEntryClass.h"

@implementation BankLoginFactory

+ (id<BankLogin, NSObject>)createLoginProxy:(NSString*)bankIdentifier
{
    id<BankLogin, NSObject> loginHelper;
    
    if ([bankIdentifier isEqualToString:@"Handelsbanken"]) {
		loginHelper = [[HandelsbankenLogin alloc] init];
	}
	else if ([bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
		loginHelper = [[LansforsakringarLogin alloc] init];
	}
	else if ([bankIdentifier isEqualToString:@"ICA"]) {
		loginHelper = [[ICABankenLogin alloc] init];
	}
    else if ([bankIdentifier isEqualToString:@"SEB"]) {
        loginHelper = [[SEBLogin alloc] init];
    }
    else if ([bankIdentifier isEqualToString:@"Swedbank"]) {
        loginHelper = [[SwedbankLogin alloc] init];
    }
    else if ([bankIdentifier isEqualToString:@"Ikano"]) {
        loginHelper = [[IkanoLogin alloc] init];
    }
    else if ([bankIdentifier isEqualToString:@"Nordea"]) {
        loginHelper = [[NordeaLogin alloc] init];
    }
	
	if ([MittSaldoSettings isDebugEnabled]) {
		loginHelper.debugLog = [[[LogEntryClass alloc] init] autorelease];
		loginHelper.debugLog.Bank = bankIdentifier;
	}
    
    return [loginHelper autorelease];
}

@end
