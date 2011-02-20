//
//  Created by Björn Sållarp on 2009-06-14.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper


+(NSMutableArray *) searchObjectsInContext:(NSString*)entityName 
								 predicate:(NSPredicate*)predicate 
								   sortKey:(NSString*)sortKey 
							 sortAscending:(BOOL)sortAscending 
					  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// If a predicate was passed, pass it to the query
	if(predicate != nil)
	{
		[request setPredicate:predicate];
	}
	
	// If a sort key was passed, use it for sorting.
	if(sortKey != nil)
	{
		NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
		NSArray *sortKeys = [sortKey componentsSeparatedByString: @","];
		
		for(int i = 0; i < [sortKeys count]; i++)
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[sortKeys objectAtIndex:i] ascending:sortAscending];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
		
		
		[request setSortDescriptors:sortDescriptors];
		[sortDescriptors release];

	}
	
	NSError *error;
	
	NSMutableArray *mutableFetchResults = [[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] autorelease];
	
	[request release];
	
	return mutableFetchResults;
}


+(NSMutableArray *) getObjectsFromContext:(NSString*)entityName 
								  sortKey:(NSString*)sortKey  
							sortAscending:(BOOL)sortAscending 
					 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsInContext:entityName 
							  predicate:nil 
								sortKey:sortKey
						  sortAscending:sortAscending 
				   managedObjectContext:managedObjectContext];
}


@end
