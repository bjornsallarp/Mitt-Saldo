//
//  Created by Björn Sållarp on 2011-02-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SEBLogin.h"
#import "MittSaldoSettings.h"

@implementation SEBLogin
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

-(void)login:(NSString*)identifier;
{
	self.settings = [BankSettings settingsForBank:identifier];
    
    // SEB is easy, we can just post pre defined values and go. No need to parse hidden ids etc. 
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"4" forKey:@"A3"]; // 4 = password
    [dict setValue:settings.username forKey:@"A1"];
    [dict setValue:settings.password forKey:@"A2"];

    [self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];
}

-(void)postLoginSucceeded:(NSString*)responseString
{
    // A valid respose is just an immediate refresh document without a body. A failed 
    // response contains a body and js-code to remove cookies
    if ([responseString rangeOfString:@"passwordLoginOK"].location != NSNotFound || 
        [responseString rangeOfString:@"redirect"].location != NSNotFound) {
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
	if(debugLog != nil) {
		[debugLog appendStep:@"postLoginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(postLoginSucceeded:) withObject:[request responseString] waitUntilDone:NO];
}

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[super dealloc];
}
@end
