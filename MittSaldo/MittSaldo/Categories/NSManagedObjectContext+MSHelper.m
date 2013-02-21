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

#import "NSManagedObjectContext+MSHelper.h"

@implementation NSManagedObjectContext (MSHelper)

+ (NSManagedObjectContext *)sharedContext
{
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(managedObjectContext)]) {
        return [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];
    }
    
    return nil;
}

+ (id)insertEntityForName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[NSManagedObjectContext sharedContext]];
}

+ (void)saveAndAlertOnError
{
    NSError * error;
    if (![[NSManagedObjectContext sharedContext] save:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                        message:[error localizedDescription]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
        [[NSManagedObjectContext sharedContext] rollback];
    }
}

- (NSMutableArray *)searchObjectsInContext:(NSString *)entityName 
								 predicate:(NSPredicate *)predicate 
								   sortKey:(NSString *)sortKey 
							 sortAscending:(BOOL)sortAscending 
{
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
	[request setEntity:entity];	
	
	// If a predicate was passed, pass it to the query
	if (predicate != nil) {
		[request setPredicate:predicate];
	}
	
	// If a sort key was passed, use it for sorting.
	if (sortKey != nil) {
		NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
		NSArray *sortKeys = [sortKey componentsSeparatedByString: @","];
		
		for (int i = 0; i < [sortKeys count]; i++) {
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[sortKeys objectAtIndex:i] ascending:sortAscending];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
				
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptors release];
	}
	
	NSError *error;
	NSMutableArray *mutableFetchResults = [[[self executeFetchRequest:request error:&error] mutableCopy] autorelease];
	[request release];
	
	return mutableFetchResults;
}


- (NSMutableArray *)getObjectsFromContext:(NSString *)entityName 
								  sortKey:(NSString *)sortKey  
							sortAscending:(BOOL)sortAscending 
{
	return [self searchObjectsInContext:entityName 
							  predicate:nil 
								sortKey:sortKey
						  sortAscending:sortAscending];
}

@end
