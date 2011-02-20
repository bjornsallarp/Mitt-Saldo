//
//  Created by Björn Sållarp on 2010-05-02.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "LoginParser.h"
#import "MittSaldoSettings.h"

@implementation LoginParser
@synthesize passwordField, usernameField, csrf_token;
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

-(void)login:(NSString*)identifier
{
	self.settings = [MittSaldoSettings settingsForBank:identifier];
	
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

-(void)postLogin
{

	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:settings.username forKey:self.usernameField];
	[dict setValue:settings.password forKey:self.passwordField];
	[dict setValue:self.csrf_token forKey:@"_csrf_token"];
	
	[self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];	
}

-(void)postLoginSucceeded:(NSString*)recievedPage
{
	if([recievedPage rangeOfString:@"_csrf_token"].length > 0)
	{
		[delegate performSelector:@selector(loginFailed:) withObject:self];
	}
	else 
	{
		[delegate performSelector:@selector(loginSucceeded:) withObject:self];
	}
}

-(void)parseLoginPage:(NSData*)downloadedData
{
	[downloadedData retain];
	
	NSError *parseError = nil;
	
	[self parseXMLData:downloadedData parseError:&parseError];
	
	if(self.csrf_token != nil && self.usernameField != nil && self.passwordField != nil)
	{
		// This is the data we parse out.
		debug_NSLog(@"Token: %@", self.csrf_token);
		debug_NSLog(@"Username field: %@", self.usernameField);
		debug_NSLog(@"Password field: %@", self.passwordField);
		
		[self postLogin];
	}	
	else
	{
		if(delegate)
		{
			debug_NSLog(@"Parse error: %@", [parseError localizedDescription]);
			self.errorMessage = @"Kunde inte avkoda loginformuläret";
			[delegate loginFailed:self];
		}
	}
	

	
	[downloadedData release];
}


#pragma mark -
#pragma mark  XML Parsing

-(BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	// Create XML parser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
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
#pragma mark Request delegates

-(void)postLoginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"postLoginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(postLoginSucceeded:) withObject:[request responseString] waitUntilDone:NO];
}

-(void)loginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseData] waitUntilDone:NO];
}

-(void)requestFailed:(ASIHTTPRequest*)request
{
	
	if(request.error != nil)
	{
		self.errorMessage = [request.error localizedDescription];
	}
	
	if(delegate)
	{
		[delegate loginFailed:self];
	}
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[csrf_token release];
	[usernameField release];
	[passwordField release];
	
	[super dealloc];
}



@end
