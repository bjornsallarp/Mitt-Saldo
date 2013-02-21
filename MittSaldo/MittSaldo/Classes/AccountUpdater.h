//
//  Created by Björn Sållarp on 2010-05-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>

@class MSConfiguredBank;
@class MSLParsedAccount;

typedef void (^MSAccountUpdaterSuccessBlock)(MSConfiguredBank *completedBank);
typedef void (^MSAccountUpdaterFailureBlock)(MSConfiguredBank *failedBank, NSError *error, NSString *message);

@interface AccountUpdater : NSObject

+ (void)persistAccountBalance:(MSConfiguredBank *)service accounts:(NSArray *)parsedAccounts;

- (void)enqueueBankForUpdate:(MSConfiguredBank *)bank;
- (BOOL)isUpdatingBankWithGuid:(NSString *)guid;
- (NSArray *)banksBeingUpdated;

@property (nonatomic, copy) MSAccountUpdaterSuccessBlock successBlock;
@property (nonatomic, copy) MSAccountUpdaterFailureBlock failureBlock;
@property (nonatomic, readonly) BOOL isUpdating;


@end


