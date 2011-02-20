//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "ICABankenLogin.h"
#import "MittSaldoSettings.h"

@implementation ICABankenLogin
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

-(void)login:(NSString*)identifier;
{
	self.settings = [MittSaldoSettings settingsForBank:identifier];

	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

-(void)parseLoginPage:(NSString*)reponseString
{
	// The response is HTML, not XHTML. In order for the parser not to choke we simply remove the &-characters
	NSString *fixedMarkup = [reponseString stringByReplacingOccurrencesOfString:@"&" withString:@""];
	
	ICABankenLoginParser *loginParser = [[ICABankenLoginParser alloc] init];
	NSError *error = nil;
	
	if([loginParser parseXMLData:[fixedMarkup dataUsingEncoding:NSUTF8StringEncoding] parseError:&error])
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:settings.username forKey:@"pnr_phone"];
		[dict setValue:settings.password forKey:@"pwd_phone"];
		
		// Add all the hidden fields we previously parsed from the login-page
		for(NSString *key in loginParser.hiddenFields)
		{
			[dict setValue:[loginParser.hiddenFields valueForKey:key] forKey:key];
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

-(void)postLoginSucceeded:(NSURL*)destinationURL
{
	// ICA Banken moves the user to a new page if login succeded, if we are still on the login
	// page after posting successfully the login failed
	if([[destinationURL absoluteString] isEqualToString:[settings.loginURL absoluteString]])
	{
		[delegate performSelector:@selector(loginFailed:) withObject:self];
	}
	else 
	{
		[delegate performSelector:@selector(loginSucceeded:) withObject:self];		
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
	
	[self performSelectorOnMainThread:@selector(postLoginSucceeded:) withObject:[request url] waitUntilDone:NO];
}

-(void)loginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseString] waitUntilDone:NO];
}


#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[super dealloc];
}

@end
