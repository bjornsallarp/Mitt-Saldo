//
//  Created by Björn Sållarp on 2011-04-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//
#import "SwedbankLoginParser.h"


@implementation SwedbankLoginParser
@synthesize csrf_token, usernameField, passwordField, nextLoginStepUrl;

-(BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	// Create XML parser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    // We get a new csrf token for each parse, set to nil. 
    // IMPORTANT. Otherwise the next step url isn't parsed correctly!
    self.csrf_token = nil;
    
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
        
		successfull = FALSE;
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
	if([elementName isEqualToString:@"input"])
	{
		if([[attributeDict valueForKey:@"name"] isEqualToString:@"_csrf_token"])
		{
			self.csrf_token = [attributeDict valueForKey:@"value"];
		}
		else if(([[attributeDict valueForKey:@"autocomplete"] isEqualToString:@"off"] && 
				 [[attributeDict valueForKey:@"type"] isEqualToString:@"number"]) || 
				[[attributeDict valueForKey:@"maxlength"] isEqualToString:@"12"] ||
				[[attributeDict valueForKey:@"maxlength"] isEqualToString:@"13"]) {
			self.usernameField = [attributeDict valueForKey:@"name"];
		}
		else if([[attributeDict valueForKey:@"autocomplete"] isEqualToString:@"off"] && 
				([[attributeDict valueForKey:@"maxlength"] isEqualToString:@"6"] || [[attributeDict valueForKey:@"maxlength"] isEqualToString:@"4"])) {
			self.passwordField = [attributeDict valueForKey:@"name"];
		}
	}
    // Check if we already have a csrf token, if so, there is another sneaky form on the page!
    else if([elementName isEqualToString:@"form"] && self.csrf_token == nil)
    {
        self.nextLoginStepUrl = [attributeDict valueForKey:@"action"];
    }
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{ 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}



#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[csrf_token release];
	[usernameField release];
	[passwordField release];
    [nextLoginStepUrl release];
	
	[super dealloc];
}

@end
