//
//  Created by Björn Sållarp on 2010-07-18.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "HandelsbankenMenuParser.h"


@implementation HandelsbankenMenuParser
@synthesize menuLinks;

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	isParsingMenu = NO;
	self.menuLinks = [NSMutableArray array];
	
	
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
	
	
	// These are the elements we read information from.
	if([elementName isEqualToString:@"ul"])
	{
		if([[attributeDict valueForKey:@"class"] isEqualToString:@"list"])
		{
			isParsingMenu = YES;
		}	
	}
	else if(isParsingMenu == YES && [elementName isEqualToString:@"a"])
	{
		// Create a complete url. The urls in the markup is relative
		NSString *url = [NSString stringWithFormat:@"https://m.handelsbanken.se%@", [attributeDict valueForKey:@"href"]]; 
		[menuLinks addObject:url];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
	if([elementName isEqualToString:@"ul"] && isParsingMenu)
	{
		isParsingMenu = NO;
	}
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[menuLinks release];
	[super dealloc];
}

@end
