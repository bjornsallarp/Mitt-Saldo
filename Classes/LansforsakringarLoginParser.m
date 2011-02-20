//
//  Created by Björn Sållarp on 2011-01-06.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "LansforsakringarLoginParser.h"


@implementation LansforsakringarLoginParser
@synthesize hiddenFields;

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
		
		successfull = FALSE;
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
	
	if([elementName isEqualToString:@"form"])
	{
		if([[attributeDict valueForKey:@"name"] isEqualToString:@"login"])
		{
			inLoginForm = YES;
		}
		else {
			inLoginForm = NO;
		}

	}
	else if(inLoginForm)
	{
		// Store all the hidden fields. ASP.NET stores some viewstate information in hidden inputfields that 
		// are required for a successful postback
		if([elementName isEqualToString:@"input"])
		{
			if([[attributeDict valueForKey:@"type"] isEqualToString:@"hidden"])
			{
				[hiddenFields setObject:[attributeDict valueForKey:@"value"] forKey:[attributeDict valueForKey:@"name"]];
			}
		}
	}
}


#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[hiddenFields release];
	[super dealloc];
}

@end
