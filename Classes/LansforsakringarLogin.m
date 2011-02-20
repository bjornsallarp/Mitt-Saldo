//
//  Created by Björn Sållarp on 2011-01-06.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "LansforsakringarLogin.h"
#import "MittSaldoSettings.h"
#import "LansforsakringarLoginParser.h"

@implementation LansforsakringarLogin

@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;
@synthesize loginResponse, loginURL, loginResponseData;

-(void)login:(NSString*)identifier;
{
	self.settings = [MittSaldoSettings settingsForBank:identifier];
	
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

-(void)parseLoginPage:(NSData*)responseData
{
	LansforsakringarLoginParser *loginParser = [[LansforsakringarLoginParser alloc] init];
	NSError *error = nil;
	
	if([loginParser parseXMLData:responseData parseError:&error])
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:settings.username forKey:@"userId"];
		[dict setValue:settings.password forKey:@"pin"];
		[dict setValue:@"loginButton" forKey:@"loginButton"];
		
		// Add all the hidden fields we previously parsed from the login-page
		for(NSString *key in loginParser.hiddenFields)
		{
			[dict setValue:[loginParser.hiddenFields valueForKey:key] forKey:key];
			
			debug_NSLog(@"%@ -> %@", key, [loginParser.hiddenFields valueForKey:key]);
		}
		
		[self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];	
	}
	else 
	{
		self.errorMessage = @"Kunde inte avkoda inloggningsformuläret";
		
		if(delegate)
		{
			[delegate loginFailed:self];
		}
	}
	
	[loginParser release];
	
}

-(void)postLoginSucceeded:(id)request
{
	if([[request responseString] rangeOfString:@"logout"].location != NSNotFound)
	{
		self.loginResponseData = [request responseData];
		self.loginResponse = [request responseString];
		self.loginURL = [request url];
		[delegate performSelector:@selector(loginSucceeded:) withObject:self];		
	}
	else {
		[delegate performSelector:@selector(loginFailed:) withObject:self];		
	}
}

#pragma mark -
#pragma mark Request delegates

-(void)postLoginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"postLoginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	debug_NSLog(@"Ended up at: %@", [request url]);
	
	[self performSelectorOnMainThread:@selector(postLoginSucceeded:) withObject:request waitUntilDone:NO];
}

-(void)loginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseData] waitUntilDone:NO];
}


#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[loginResponseData release];
	[loginResponse release];
	[loginURL release];
	[super dealloc];
}
@end
