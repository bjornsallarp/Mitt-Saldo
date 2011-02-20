//
//  Created by Björn Sållarp on 2010-08-10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BankLoginBase.h"
#import "MittSaldoSettings.h"

@implementation BankLoginBase
@synthesize settings, errorMessage, delegate, wasCancelled, debugLog;


-(void)fetchLoginPage:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector
{
	NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
	
	loginRequest = [[ASIHTTPRequest alloc] initWithURL:settings.loginURL];
	[loginRequest setDelegate:requestDelegate];
	[loginRequest setDidFailSelector:failSelector];
	[loginRequest setDidFinishSelector:successSelector];
	
	if(settings.requestTimeout > 0)
	{
		loginRequest.timeOutSeconds = settings.requestTimeout;
	}
	
	// We want to set our user agent so it's not obvious that we are using a custom app to make the requests.
	[loginRequest addRequestHeader:@"User-Agent" value:[usrDef valueForKey:@"WebViewUserAgent"]];
	 
	if(debugLog != nil)
	{
		[debugLog appendStep:@"fetchLoginPage" logContent:[NSString stringWithFormat:@"LoginURL: %@\r\nUser Agent: %@", settings.loginURL, [usrDef valueForKey:@"WebViewUserAgent"]]];
	}
	
	[loginRequest startAsynchronous];
}

-(void)postLogin:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector postValues:(NSDictionary*)postValues
{
	NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
	
	// Build the request
	loginPostRequest = [[ASIFormDataRequest alloc] initWithURL:settings.loginURL];
	[loginPostRequest setDidFailSelector:failSelector];
	[loginPostRequest setDidFinishSelector:successSelector];
	[loginPostRequest setDelegate:requestDelegate];
	
	if(settings.requestTimeout > 0)
	{
		loginPostRequest.timeOutSeconds = settings.requestTimeout;
	}

    [loginPostRequest addRequestHeader:@"Referer" value:@"https://m.seb.se/cgi-bin/pts3/mpo/9000/mpo9001.aspx?P1=logon.htm"];
	
	// We want to set our user agent so it's not obvious that we are using a custom app to make the requests.
	[loginPostRequest addRequestHeader:@"User-Agent" value:[usrDef valueForKey:@"WebViewUserAgent"]];
	
	for(NSString* key in postValues)
	{
		[loginPostRequest addPostValue:[postValues objectForKey:key] forKey:key];		
	}
	
	if(debugLog != nil)
	{
		[debugLog appendStep:@"postLogin" logContent:[NSString stringWithFormat:@"LoginURL: %@\r\nUser Agent: %@", settings.loginURL, [usrDef valueForKey:@"WebViewUserAgent"]]];
	}

	[loginPostRequest startAsynchronous];
	
}

-(void)cancelOperation
{
	// Remove the cookies so next update starts out fresh
	[MittSaldoSettings removeCookiesForBank:settings.bankIdentifier];
	
	wasCancelled = YES;
	
	[loginRequest cancel];
	[loginPostRequest cancel];
}



-(void)requestFailed:(ASIHTTPRequest*)request
{
	// Remove the cookies so next update starts out fresh
	[MittSaldoSettings removeCookiesForBank:settings.bankIdentifier];
	
	if(request.error != nil)
	{
		self.errorMessage = [request.error localizedDescription];
	}
	
	if(delegate)
	{
		// This typecast is only there to avoid the compilation warning.
		// make sure the class that inherit and use this method implement BankLogin!
		[delegate loginFailed:(id<BankLogin>)self];
	}
}


-(void)dealloc
{
	// Cancel any running requests
	[loginRequest clearDelegatesAndCancel];
	[loginPostRequest clearDelegatesAndCancel];
	
	[loginRequest release];
	[loginPostRequest release];
	[errorMessage release];
	[settings release];
	[debugLog release];
	[super dealloc];
}

@end
