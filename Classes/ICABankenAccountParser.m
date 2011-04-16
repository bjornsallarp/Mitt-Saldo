//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "ICABankenAccountParser.h"
#import "BankAccount.h"
#import "CoreDataHelper.h"


@interface ICABankenAccountParser()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *currentAccount;
@property (nonatomic, retain) NSMutableString *elementInnerContent;
@end

@implementation ICABankenAccountParser
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
	
	// These are the elements we read information from.
	if (!self.currentAccount && [elementName isEqualToString:@"div"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"row"] && [attributeDict valueForKey:@"onmousedown"] != nil) {
		NSString *accountId = [NSString stringWithFormat:@"%d", accountsParsed];
		NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
																		   predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'ICA')", accountId] 
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
		[self.currentAccount setBankIdentifier:@"ICA"];
		[self.currentAccount setUpdatedDate:[NSDate date]];
	}
	else if (self.currentAccount) {
        if ([elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"form-label"]) {
            isParsingName = YES;
        }
        else if (isParsingName && [elementName isEqualToString:@"span"] && [attributeDict valueForKey:@"title"] != nil) {
            self.currentAccount.accountName = [attributeDict valueForKey:@"title"];
            isParsingName = NO;
        }
        else if([elementName isEqualToString:@"div"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"upper"]) {
            isParsingAmount = YES;
        }
        else if(isParsingAmount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"right"]) {
            self.elementInnerContent = [NSMutableString string];
        }
        else if([elementName isEqualToString:@"div"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"lower"]) {
            isParsingAvailableAmount = YES;
        }
        else if(isParsingAvailableAmount && [elementName isEqualToString:@"span"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"right"]) {
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
    
	if((isParsingAmount || isParsingAvailableAmount) && [elementName isEqualToString:@"span"] && self.elementInnerContent) {
        NSString *amountString = self.elementInnerContent;
        NSMutableString *strippedAmountString = [NSMutableString string];
        for (int i = 0; i < [amountString length]; i++) {
            if (isdigit([amountString characterAtIndex:i]) || [amountString characterAtIndex:i] == ',' || [amountString characterAtIndex:i] == '-') {
                [strippedAmountString appendFormat:@"%c", [amountString characterAtIndex:i]];
            }
        }
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		[f setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
		NSNumber *amountValue = [f numberFromString:strippedAmountString];
        [f release];
        
		if(isParsingAmount) {
			self.currentAccount.amount = amountValue;
			isParsingAmount = NO;
		}
		else if(isParsingAvailableAmount) {
			self.currentAccount.availableAmount = amountValue;
			isParsingAvailableAmount = NO;
            
            debug_NSLog(@"%@. %@ -> %@ kr. Disponibelt: %@", self.currentAccount.accountid, self.currentAccount.accountName, 
                        self.currentAccount.amount, self.currentAccount.availableAmount);
            
            NSError * error;
            // Store the objects
            if (![self.managedObjectContext save:&error]) {
                // Handle the error?
                NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
            }
            
            self.accountsParsed++;
            self.currentAccount = nil;
		}
        
        self.elementInnerContent = nil;
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
