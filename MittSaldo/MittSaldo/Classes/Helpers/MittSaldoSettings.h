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
#import <CoreData/CoreData.h>

@class MSConfiguredBank;

@interface MittSaldoSettings : NSObject

+ (NSArray *)configuredBanks;
+ (void)resetAllPersonalInformation;
+ (void)removeConfiguredBank:(MSConfiguredBank *)bank;

+ (void)setApplicationDidEnterBackground:(NSDate *)date;
+ (NSDate*)getApplicationDidEnterBackground;

+ (BOOL)isKeyLockActive;

+ (BOOL)isTactivoLockActive;
+ (BOOL)isTactivoEnabled;
+ (void)setIsTactivoEnabled:(BOOL)isEnabled;

+ (void)setIsUpdateOnStartEnabled:(BOOL)isEnabled;
+ (BOOL)isUpdateOnStartEnabled;

+ (NSNumber *)getKeyLockFailedAttempts;
+ (void)setKeyLockFailedAttempts:(int)attempts;
+ (NSArray *)getKeyLockCombination;
+ (void)setKeyLockCombination:(NSArray *)combo;

+ (void)setAlreadyRatedApp;
+ (BOOL)isAppRated;
+ (BOOL)hasPaidForApp;
+ (int)multitaskingTimeout;
@end
