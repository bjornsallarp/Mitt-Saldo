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

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (MSHelper)

+ (NSManagedObjectContext *)sharedContext;
+ (id)insertEntityForName:(NSString *)entityName;
+ (void)saveAndAlertOnError;

- (NSMutableArray *)searchObjectsInContext:(NSString *)entityName 
								 predicate:(NSPredicate *)predicate 
								   sortKey:(NSString *)sortKey 
							 sortAscending:(BOOL)sortAscending;

- (NSMutableArray *)getObjectsFromContext:(NSString *)entityName 
								  sortKey:(NSString *)sortKey  
							sortAscending:(BOOL)sortAscending;

@end
