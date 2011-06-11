//
//  IKANOLoginParser.m
//  MittSaldo
//
//  Created by Björn Sållarp on 5/26/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "IkanoLoginParser.h"


@implementation IkanoLoginParser
@synthesize hiddenFields = hiddenFields_;
@synthesize ssnFieldName = ssnFields_;
@synthesize passwordFieldName = passwordField_;

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	self.hiddenFields = [NSMutableDictionary dictionary];
	
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
	
	// Store all the hidden fields. ASP.NET stores some viewstate information in hidden inputfields that 
	// are required for a successful postback
	if([elementName isEqualToString:@"input"]) {
        NSString *inputType = [attributeDict valueForKey:@"type"];
        NSString *inputValue = [attributeDict valueForKey:@"value"];
        
		if ([inputType isEqualToString:@"hidden"]) {
            if ([attributeDict valueForKey:@"name"] != nil) {
                [self.hiddenFields setObject:inputValue forKey:[attributeDict valueForKey:@"name"]];
            }
            else if ([attributeDict valueForKey:@"id"] != nil) {
                [self.hiddenFields setObject:inputValue forKey:[attributeDict valueForKey:@"id"]];                
            }
		}
        else if ([inputType isEqualToString:@"password"]) {
            self.passwordFieldName = [attributeDict valueForKey:@"name"];
        }
        else if ([inputType isEqualToString:@"text"] && [[attributeDict valueForKey:@"maxlength"] isEqualToString:@"12"]) {
            self.ssnFieldName = [attributeDict valueForKey:@"name"];
        }
	}
    else if (self.ssnFieldName && self.passwordFieldName && [elementName isEqualToString:@"a"] && [[[attributeDict valueForKey:@"id"] lowercaseString] rangeOfString:@"login"].location != NSNotFound) {
        [self.hiddenFields setObject:[[attributeDict valueForKey:@"id"] stringByReplacingOccurrencesOfString:@"_" withString:@"$"] forKey:@"__EVENTTARGET"];
    }
    
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	self.hiddenFields = nil;
	self.ssnFieldName = nil;
    self.passwordFieldName = nil;
	[super dealloc];
}
@end
