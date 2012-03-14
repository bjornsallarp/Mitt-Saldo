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

@interface BankLoginBase()
@property (nonatomic, retain) ASIHTTPRequest *loginRequest;
@property (nonatomic, retain) ASIFormDataRequest *loginPostRequest;
@end

@implementation BankLoginBase
@synthesize settings, errorMessage, delegate, wasCancelled, debugLog;
@synthesize loginPostRequest, loginRequest;

-(void)fetchLoginPage:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector
{
    if (self.loginRequest != nil) {
        [self.loginRequest clearDelegatesAndCancel];
        self.loginRequest = nil;
    }
    
	NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
	
	self.loginRequest = [ASIHTTPRequest requestWithURL:settings.loginURL];
    self.loginRequest.timeOutSeconds = 20;
	[self.loginRequest setDelegate:requestDelegate];
	[self.loginRequest setDidFailSelector:failSelector];
	[self.loginRequest setDidFinishSelector:successSelector];
	
	if (settings.requestTimeout > 0) {
		self.loginRequest.timeOutSeconds = settings.requestTimeout;
	}
	
	// We want to set our user agent so it's not obvious that we are using a custom app to make the requests.
	[self.loginRequest addRequestHeader:@"User-Agent" value:[usrDef valueForKey:@"WebViewUserAgent"]];
	 
	if (debugLog != nil) {
		[debugLog appendStep:@"fetchLoginPage" logContent:[NSString stringWithFormat:@"LoginURL: %@\r\nUser Agent: %@", settings.loginURL, [usrDef valueForKey:@"WebViewUserAgent"]]];
	}
	
	[self.loginRequest startAsynchronous];
}

-(void)postLogin:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector postValues:(NSDictionary*)postValues
{
    if (self.loginPostRequest != nil) {
        [self.loginPostRequest clearDelegatesAndCancel];
        self.loginPostRequest = nil;
    }
    
	NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
	
	// Build the request
	self.loginPostRequest = [ASIFormDataRequest requestWithURL:settings.loginURL];
    self.loginRequest.timeOutSeconds = 20;
	[self.loginPostRequest setDidFailSelector:failSelector];
	[self.loginPostRequest setDidFinishSelector:successSelector];
	[self.loginPostRequest setDelegate:requestDelegate];
	
	if (settings.requestTimeout > 0) {
		self.loginPostRequest.timeOutSeconds = settings.requestTimeout;
	}

    [self.loginPostRequest addRequestHeader:@"Referer" value:[settings.loginURL absoluteString]];
    
	// We want to set our user agent so it's not obvious that we are using a custom app to make the requests.
	[self.loginPostRequest addRequestHeader:@"User-Agent" value:[usrDef valueForKey:@"WebViewUserAgent"]];
	
	for (NSString* key in postValues) {
		[self.loginPostRequest addPostValue:[postValues objectForKey:key] forKey:key];		
	}
	
	if (debugLog != nil) {
		[debugLog appendStep:@"postLogin" logContent:[NSString stringWithFormat:@"LoginURL: %@\r\nUser Agent: %@", settings.loginURL, [usrDef valueForKey:@"WebViewUserAgent"]]];
	}

	[self.loginPostRequest startAsynchronous];
}

-(void)cancelOperation
{
	// Remove the cookies so next update starts out fresh
	[MittSaldoSettings removeCookiesForBank:settings.bankIdentifier];
	
	wasCancelled = YES;
	
	[self.loginRequest clearDelegatesAndCancel];
	[self.loginPostRequest clearDelegatesAndCancel];
    self.loginRequest = nil;
    self.loginPostRequest = nil;
}



-(void)requestFailed:(ASIHTTPRequest*)request
{
	// Remove the cookies so next update starts out fresh
	[MittSaldoSettings removeCookiesForBank:settings.bankIdentifier];
	
	if (request.error != nil) {
		self.errorMessage = [request.error localizedDescription];
	}
	
	if (delegate) {
		// This typecast is only there to avoid the compilation warning.
		// make sure the class that inherit and use this method implement BankLogin!
		[delegate loginFailed:(id<BankLogin>)self];
	}
}


-(void)dealloc
{
	// Cancel any running requests
	[self.loginRequest clearDelegatesAndCancel];
	[self.loginPostRequest clearDelegatesAndCancel];
	
	[loginRequest release];
	[loginPostRequest release];
	[errorMessage release];
	[settings release];
	[debugLog release];
	[super dealloc];
}

@end
