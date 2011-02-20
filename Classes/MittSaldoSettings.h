//
//  Created by Björn Sållarp on 2010-07-24.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//


#import <Foundation/Foundation.h>
#import "AccountSettings.h"

@interface MittSaldoSettings : NSObject {

}

+(NSArray*)configuredBanks;
+(NSString*)bankShortName:(NSString*)bankIdentifier;
+(void)loadStandardSettings;
+(void)resetAllPersonalInformation;
+(NSArray*)supportedBanks;
+(BOOL)isBankConfigured:(NSString*)bankIdentifier;
+(void)removeCookiesForBank:(NSString*)bankIdentifier;
+(AccountSettings*)settingsForBank:(NSString*)bankIdentifier;

+(void)setApplicationDidEnterBackground:(NSDate*)date;
+(NSDate*)getApplicationDidEnterBackground;

+(BOOL)isKeyLockActive;
+(NSNumber*)getKeyLockFailedAttempts;
+(void)setKeyLockFailedAttempts:(int)attempts;
+(NSArray*)getKeyLockCombination;
+(void)setKeyLockCombination:(NSArray*)combo;

+(void)setAlreadyRatedApp;
+(BOOL)isAppRated;
+(int)multitaskingTimeout;
+(BOOL)isDebugEnabled;

@end
