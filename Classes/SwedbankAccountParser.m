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

@interface SwedbankAccountParser()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *currentAccount;
@property (nonatomic, retain) NSMutableString *elementInnerContent;
@end

@implementation SwedbankAccountParser
@synthesize elementInnerContent = elementInnerContent_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize currentAccount = currentAccount_;
@synthesize accountsParsed;

- (id)initWithContext:(NSManagedObjectContext *)context
{
	self = [super init];
	self.managedObjectContext = context;
    return self;
}

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successfull = YES;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    // Start parsing
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		successfull = NO;
    }
    
    [parser release];
	
	return successfull;
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
	if ([elementName isEqualToString:@"a"] && [attributeDict valueForKey:@"accesskey"] != nil) {
        // Check to see if the account already exist in our database
		NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
                                                                           predicate:[NSPredicate predicateWithFormat:@"(accountid == %d) && (bankIdentifier == 'Swedbank')", accountsParsed] 
                                                                             sortKey:@"accountid" 
                                                                       sortAscending:YES 
                                                                managedObjectContext:self.managedObjectContext];
		if([mutableFetchResults count] > 0) {
			self.currentAccount = (BankAccount*)[mutableFetchResults objectAtIndex:0];
		}
		else {
			// Create a new account entity
			self.currentAccount = (BankAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
		}
        
        [self.currentAccount setBankIdentifier:@"Swedbank"];
		[self.currentAccount setUpdatedDate:[NSDate date]];
        [self.currentAccount setAccountid:[NSNumber numberWithInt:accountsParsed]];
	}
	else if (self.currentAccount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"name"]) {
		isParsingName = YES;
        self.elementInnerContent = [NSMutableString string];
	}
	else if (self.currentAccount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"amount"]) {
        isParsingAmount = YES;
        self.elementInnerContent = [NSMutableString string];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"a"] && self.currentAccount) {
		debug_NSLog(@"%@. %@ -> %@ kr", self.currentAccount.accountid, self.currentAccount.accountName, self.currentAccount.amount);
		
		NSError * error;
		// Store the objects
		if (![self.managedObjectContext save:&error]) {
			// Log the error.
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
        
        self.currentAccount = nil;
	}
	else if ([elementName isEqualToString:@"span"] && isParsingName) {
        self.currentAccount.accountName = self.elementInnerContent;
		isParsingName = NO;
        self.elementInnerContent = nil;
	}
	else if ([elementName isEqualToString:@"span"] && isParsingAmount) {
		[self.currentAccount setAvailableAmountWithString:self.elementInnerContent];
		isParsingAmount = NO;
		accountsParsed++;
        self.elementInnerContent = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementInnerContent appendString:string];
}

#pragma mark - Memory management
-(void)dealloc
{
	self.elementInnerContent = nil;
	self.managedObjectContext = nil;
    self.currentAccount = nil;
	[super dealloc];
}

@end
