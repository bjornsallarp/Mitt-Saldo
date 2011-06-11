//
//  IkanoAccountParser.m
//  MittSaldo
//
//  Created by Björn Sållarp on 5/28/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "IkanoAccountParser.h"
#import "BankAccount.h"
#import "CoreDataHelper.h"

@interface IkanoAccountParser()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *currentAccount;
@property (nonatomic, retain) NSMutableString *elementInnerContent;
@end

@implementation IkanoAccountParser
@synthesize elementInnerContent = contentsOfCurrentProperty_;
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
	BOOL successfull = TRUE;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
    self.accountsParsed = 0;
    
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

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }

    if ([elementName isEqualToString:@"table"] && self.accountsParsed == 0) {
        isParsingAccounts = YES;
    }
	else if (isParsingAccounts) {
        if ([elementName isEqualToString:@"a"]) {
            NSString *accountId = [NSString stringWithFormat:@"%d", accountsParsed];
            NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
                                                                               predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'Ikano')", accountId] 
                                                                                 sortKey:@"accountid" 
                                                                           sortAscending:YES 
                                                                    managedObjectContext:self.managedObjectContext];
            if ([mutableFetchResults count] > 0) {
                self.currentAccount = (BankAccount*)[mutableFetchResults objectAtIndex:0];
            }
            else {
                self.currentAccount = (BankAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
            }
            
            [self.currentAccount setAccountid:[NSNumber numberWithInt:accountsParsed]];
            [self.currentAccount setBankIdentifier:@"Ikano"];
            [self.currentAccount setUpdatedDate:[NSDate date]];
            
            self.elementInnerContent = [NSMutableString string];
        }
        else if ([elementName isEqualToString:@"td"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"txt-right"]) {
            isParsingAmount = YES;
            self.elementInnerContent = [NSMutableString string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
    if (isParsingAccounts && [elementName isEqualToString:@"a"]) {
        [self.currentAccount setAccountName:self.elementInnerContent];
        self.elementInnerContent = nil;
    }
    else if (isParsingAmount && [elementName isEqualToString:@"td"] && self.elementInnerContent) {        
        [self.currentAccount setAmountWithString:self.elementInnerContent];
        
        debug_NSLog(@"%@. %@ -> %@ kr", self.currentAccount.accountid, self.currentAccount.accountName, self.currentAccount.amount);
        
        NSError * error;
        // Store the objects
        if (![self.managedObjectContext save:&error]) {
            // Handle the error?
            NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
        }
            
        isParsingAmount = NO;
        self.accountsParsed++;
        self.currentAccount = nil;
        self.elementInnerContent = nil;
	}
    else if (isParsingAccounts && [elementName isEqualToString:@"table"]) {
        isParsingAccounts = NO;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.elementInnerContent) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.elementInnerContent appendString:string];
    }
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
