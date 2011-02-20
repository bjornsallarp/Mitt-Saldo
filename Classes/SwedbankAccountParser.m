//
//  Created by Björn Sållarp on 2010-05-15.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SwedbankAccountParser.h"


@implementation SwedbankAccountParser
@synthesize contentsOfCurrentProperty, accountsParsed;


-(id) initWithContext: (NSManagedObjectContext *) context
{
	self = [super init];
	managedObjectContext = context;
	[managedObjectContext retain];
	
	return self;
}

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	isParsingAccounts = NO;
	
    // Start parsing
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		
		successfull = FALSE;
    }
    
    [parser release];
	
	return successfull;
}


-(void)emptyCurrentProperty
{
	// Create a mutable string to hold the contents of the 'title' element.
	// The contents are collected in parser:foundCharacters:.
	if(self.contentsOfCurrentProperty == nil)
	{
		self.contentsOfCurrentProperty = [NSMutableString string];
	}
	else
		[self.contentsOfCurrentProperty setString:@""];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }
	

	// These are the elements we read information from.
	if([elementName isEqualToString:@"ul"])
	{
		if([[attributeDict valueForKey:@"class"] isEqualToString:@"grouped"])
		{
			isParsingAccounts = YES;
		}	
	}
	else if(isParsingAccounts == YES && [elementName isEqualToString:@"a"])
	{
		isParsingAccount = YES;
		
		currentAccount = nil;
		
		// Check to see if the account already exist in our database
		NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
																					predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'Swedbank')", [attributeDict valueForKey:@"accesskey"]] 
																					sortKey:@"accountid" 
																					sortAscending:YES 
																					managedObjectContext:managedObjectContext];
		if([mutableFetchResults count] > 0)
		{
			currentAccount = (BankAccount*)[mutableFetchResults objectAtIndex:0];
		}
		else 
		{
			// Create a new account entity
			currentAccount = (BankAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:managedObjectContext];
		}
		
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		[currentAccount setAccountid:[f numberFromString:[attributeDict valueForKey:@"accesskey"]]];
		[currentAccount setBankIdentifier:@"Swedbank"];
		[currentAccount setUpdatedDate:[NSDate date]];
		
		[f release];
		 
		[self emptyCurrentProperty];
	}
	else if(isParsingAccount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"icon"])
	{
		isParsingIcon = YES;
	}
	else if(isParsingAccount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"secondary"])
	{		
        NSString *accountName = [self.contentsOfCurrentProperty stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
        
        // If the account name changed we update and also change the user set account name.
        if(![accountName isEqualToString:currentAccount.accountName])
        {
            [currentAccount setAccountName: accountName];
            [currentAccount setDisplayName: accountName];
        }
		
		isParsingAmount = YES;
		[self emptyCurrentProperty];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
	
	if([elementName isEqualToString:@"ul"] && isParsingAccounts)
	{
		isParsingAccounts = NO;
	}
	else if([elementName isEqualToString:@"a"] && isParsingAccount)
	{
		isParsingAccount = NO;
		
		debug_NSLog(@"%@. %@ -> %@ kr", currentAccount.accountid, currentAccount.accountName, currentAccount.amount);
		
		NSError * error;
		// Store the objects
		if (![managedObjectContext save:&error]) {
			
			// Log the error.
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
			
		}
	}
	else if([elementName isEqualToString:@"span"] && isParsingIcon)
	{
		[self emptyCurrentProperty];
		isParsingIcon = NO;
	}
	else if([elementName isEqualToString:@"span"] && isParsingAmount)
	{
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		NSString *cleanAmount = [self.contentsOfCurrentProperty stringByReplacingOccurrencesOfString:@" " withString:@""];
		cleanAmount = [cleanAmount stringByReplacingOccurrencesOfString:@"." withString:@""];
		
		[currentAccount setAmount:[f numberFromString:cleanAmount]];		
		
		[f release];
		
		isParsingAmount = NO;
		accountsParsed++;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.contentsOfCurrentProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentsOfCurrentProperty appendString:string];
    }
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[contentsOfCurrentProperty release];
	[managedObjectContext release];
	[super dealloc];
}

@end
