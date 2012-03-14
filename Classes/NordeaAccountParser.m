//
//  Created by Björn Sållarp on 2010-06-06.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "NordeaAccountParser.h"

@interface NordeaAccountParser()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *currentAccount;
@property (nonatomic, retain) NSMutableString *elementInnerContent;
@end

@implementation NordeaAccountParser
@synthesize elementInnerContent = elementInnerContent_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize currentAccount = currentAccount_;
@synthesize accountsParsed;


- (id)initWithContext: (NSManagedObjectContext *) context
{
	self = [super init];
	self.managedObjectContext = context;
	return self;
}

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
    // The pesky inline javascript (not wrapped on CDATA as they should!) need to go for the markup to be valid xhtml
    NSString *html = [[NSString alloc] initWithData:XMLMarkup encoding:NSISOLatin1StringEncoding];
    NSString *regexToReplaceRawLinks = @"<script[\\d\\D]*?>[\\d\\D]*?</script>";   
    NSError *regexError = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexError];
    NSString *cleanHtml = [regex stringByReplacingMatchesInString:html
                                                          options:0
                                                            range:NSMakeRange(0, [html length])
                                                     withTemplate:@""];
    
    NSData *cleanHtmlData = [cleanHtml dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
    
	BOOL successfull = YES;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:cleanHtmlData];
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
	if ([elementName isEqualToString:@"ul"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"list"]) {
		isParsingAccounts = YES;
	}
	else if (isParsingAccounts && [elementName isEqualToString:@"a"]) {
        NSString *accountUrl = [attributeDict valueForKey:@"href"];
		NSString *accountId = [accountUrl substringFromIndex:[accountUrl rangeOfString:@":"].location+1];
		
		// Check to see if the account already exist in our database
		NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
																					predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'Nordea')", accountId] 
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
		
		NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		[self.currentAccount setAccountid:[f numberFromString:accountId]];
		[self.currentAccount setBankIdentifier:@"Nordea"];
		[self.currentAccount setUpdatedDate:[NSDate date]];

        self.elementInnerContent = [NSMutableString string];
	}
	else if (self.currentAccount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"linkinfoRight"]) { 
        self.currentAccount.accountName = self.elementInnerContent;
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
    
	
	if ([elementName isEqualToString:@"ul"] && isParsingAccounts) {
		isParsingAccounts = NO;
	}
	else if ([elementName isEqualToString:@"a"] && self.currentAccount) {		
		debug_NSLog(@"%@. %@ -> %@ kr", self.currentAccount.accountid, self.currentAccount.accountName, self.currentAccount.amount);
		
		NSError * error;
		// Store the objects in database
		if (![self.managedObjectContext save:&error]) {
			// Log the error
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
        
        self.currentAccount = nil;
	}
	else if([elementName isEqualToString:@"span"] && isParsingAmount)
	{
		[self.currentAccount setAmountWithString:self.elementInnerContent];
		isParsingAmount = NO;
		accountsParsed++;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementInnerContent appendString:string];
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	self.elementInnerContent = nil;
	self.managedObjectContext = nil;
    self.currentAccount = nil;
	[super dealloc];
}

@end
