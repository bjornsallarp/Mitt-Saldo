//
//  Created by Björn Sållarp on 2011-02-20.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SEBAccountParser.h"
#import "BankAccount.h"
#import "CoreDataHelper.h"

@interface SEBAccountParser()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *currentAccount;
@property (nonatomic, retain) NSMutableString *elementInnerContent;
@end

@implementation SEBAccountParser
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
		successfull = NO;
    }
    
    [parser release];
	return successfull;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }
	
	if (isParsingAccounts) {
        // These are the elements we read information from.
        if ([elementName isEqualToString:@"td"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"name"]) {
            isParsingAccount = YES;
        }
        else if (isParsingAccount) {
            if([elementName isEqualToString:@"a"]) {
                NSString *accountId = [NSString stringWithFormat:@"%d", accountsParsed];
                NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
                                                                                   predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'SEB')", accountId] 
                                                                                     sortKey:@"accountid" 
                                                                               sortAscending:YES 
                                                                        managedObjectContext:self.managedObjectContext];
                if([mutableFetchResults count] > 0) {
                    self.currentAccount = (BankAccount*)[mutableFetchResults objectAtIndex:0];
                }
                else {
                    self.currentAccount = (BankAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
                }
                
                [self.currentAccount setAccountid:[NSNumber numberWithInt:accountsParsed]];
                [self.currentAccount setBankIdentifier:@"SEB"];
                [self.currentAccount setUpdatedDate:[NSDate date]];
                
                self.elementInnerContent = [NSMutableString string];
            }
            else if ([elementName isEqualToString:@"td"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"numeric"])
            {
                if(!isParsingAmount) {
                    isParsingAmount = YES;
                }
                else {
                    isParsingAmount = NO;
                    isParsingAvailableAmount = YES;
                }
                
                self.elementInnerContent = [NSMutableString string];
            }
        }
    }
    else if (!isParsingAccounts && [elementName isEqualToString:@"th"]) {
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
    
	if (!isParsingAccounts && [elementName isEqualToString:@"th"] && [self.elementInnerContent isEqualToString:@"Konton"]) {
        isParsingAccounts = YES;
        self.elementInnerContent = nil;
    }
	else if (isParsingAccounts && [elementName isEqualToString:@"table"]) {
		isParsingAccounts = NO;
	}
	else if (isParsingAccount && [elementName isEqualToString:@"a"]) {
		self.currentAccount.accountName = self.elementInnerContent;
        self.elementInnerContent = nil;
	}
	else if ((isParsingAmount || isParsingAvailableAmount) && [elementName isEqualToString:@"td"]) {
		if(isParsingAmount) {
			[self.currentAccount setAmountWithString:self.elementInnerContent];
		}
		else if(isParsingAvailableAmount) {
			[self.currentAccount setAvailableAmountWithString:self.elementInnerContent];
			isParsingAvailableAmount = NO;
            
            debug_NSLog(@"%@. %@ -> %@ kr. Disponibelt: %@", self.currentAccount.accountid, self.currentAccount.accountName, self.currentAccount.amount, self.currentAccount.availableAmount);
            
            NSError * error;
            // Store the objects
            if (![self.managedObjectContext save:&error]) {
                // Handle the error?
                NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
            }
            
            accountsParsed++;
            isParsingAccount = NO;
            self.currentAccount = nil;
		}
        self.elementInnerContent = nil;
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
    self.currentAccount = nil;
    self.managedObjectContext = nil;
	[super dealloc];
}
@end
