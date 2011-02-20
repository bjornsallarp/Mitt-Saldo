//
//  Created by Björn Sållarp on 2010-06-21.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "HandelsbankenLogin.h"
#import "MittSaldoSettings.h"

@implementation HandelsbankenLogin
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

-(void)login:(NSString*)identifier
{
	self.settings = [MittSaldoSettings settingsForBank:identifier];
	
	// Handelsbanken can sometimes be exceptionally slow so we increase the timeout
	self.settings.requestTimeout = 30;
	
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

-(void)postLogin
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:settings.username forKey:@"username"];
	[dict setValue:settings.password forKey:@"pin"];
	[dict setValue:@"true" forKey:@"execute"];
	
	[self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];	
}




#pragma mark -
#pragma mark Response parsing methods

-(void)parseLoginPage:(NSData*)data
{
	[data retain];
	
	// First we need to parse the menu because the login page change URL over time
	NSError *error = nil;
	HandelsbankenMenuParser *menuParser = [[HandelsbankenMenuParser alloc] init];
	
	if([menuParser parseXMLData:data parseError:&error])
	{
		if([menuParser.menuLinks count] > 0)
		{
			NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
			
			// Store the url to the real login page
			self.settings.loginURL = [NSURL URLWithString:[menuParser.menuLinks objectAtIndex:0]];
			[usrDef setObject:[menuParser.menuLinks objectAtIndex:0] forKey:@"HandelsbankenLogin"];
			[usrDef synchronize];
		}
		else
		{
			self.errorMessage = @"Kunde inte avkoda inloggningsformuläret";
		}
	}
	
	[data release];
	[menuParser release];
	
	if(self.errorMessage == nil)
	{
		// Perform the actual login
		[self postLogin];
	}
	else if(delegate)
	{
		[delegate loginFailed:self];
	}
}


-(void)parsePostLogin:(NSData*)data
{
	[data retain];
	BOOL successful = NO;
	
	NSError *error = nil;
	HandelsbankenMenuParser *menuParser = [[HandelsbankenMenuParser alloc] init];
	
	if([menuParser parseXMLData:data parseError:&error])
	{
		if([menuParser.menuLinks count] >= 2)
		{
			NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
			// Upadate the settings with correct url's for this authenticated session
			[usrDef setObject:[menuParser.menuLinks objectAtIndex:0] forKey:@"HandelsbankenAccounts"];
			[usrDef setObject:[menuParser.menuLinks objectAtIndex:1] forKey:@"HandelsbankenTransfer"];
			[usrDef synchronize];
			
			successful = YES;
		}
	}
	
	[data release];
	[menuParser release];
	
	if(successful && delegate)
	{
		[delegate loginSucceeded:self];
	}
	else if(delegate)
	{
		[delegate loginFailed:self];
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
	
	debug_NSLog(@"%@", [request responseString]);
	[self performSelectorOnMainThread:@selector(parsePostLogin:) withObject:[request responseData] waitUntilDone:NO];
}

-(void)loginRequestSucceeded:(id)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	debug_NSLog(@"%@", [request responseString]);
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseData] waitUntilDone:NO];
}



#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[super dealloc];
}


@end
