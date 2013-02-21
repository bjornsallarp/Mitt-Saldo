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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MSConfiguredBank;

@interface MSBankAccount : NSManagedObject
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * bankIdentifier;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * displayAccount;
@property (nonatomic, retain) NSNumber * availableAmount;
@property (nonatomic, retain) NSNumber * accountid;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) MSConfiguredBank *configuredbank;

@end
