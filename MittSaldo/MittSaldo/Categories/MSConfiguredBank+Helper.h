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

#import "MSConfiguredBank.h"
#import "NSManagedObjectContext+MSHelper.h"

@interface MSConfiguredBank (Helper)

+ (MSConfiguredBank *)insertNewBankWithName:(NSString *)name bankIdentifier:(NSString *)bankIdentifier;

- (NSString *)ssn;
- (NSString *)password;

- (void)setSsn:(NSString *)ssn;
- (void)setPassword:(NSString *)password;

@end
