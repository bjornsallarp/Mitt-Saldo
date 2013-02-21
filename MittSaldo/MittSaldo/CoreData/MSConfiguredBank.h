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

@class MSBankAccount;

@interface MSConfiguredBank : NSManagedObject 
@property (nonatomic, retain) NSString * bankIdentifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) id bookmarkURL;
@property (nonatomic, retain) NSSet *accounts;
@end

@interface MSConfiguredBank (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(MSBankAccount *)value;
- (void)removeAccountsObject:(MSBankAccount *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;
@end
