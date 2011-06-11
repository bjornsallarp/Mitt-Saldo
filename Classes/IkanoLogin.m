//
//  IKANOLogin.m
//  MittSaldo
//
//  Created by Björn Sållarp on 5/26/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "IkanoLogin.h"
#import "MittSaldoSettings.h"

@implementation IkanoLogin
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

- (void)login:(NSString*)identifier;
{
	self.settings = [BankSettings settingsForBank:identifier];
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

- (void)parseLoginPage:(NSString*)reponseString
{
	IkanoLoginParser *loginParser = [[IkanoLoginParser alloc] init];
	NSError *error = nil;
	
	if ([loginParser parseXMLData:[reponseString dataUsingEncoding:NSUTF8StringEncoding] parseError:&error] &&
        loginParser.ssnFieldName && loginParser.passwordFieldName) {
        // Add all the hidden fields we parsed from the login-page
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:loginParser.hiddenFields];
		[dict setValue:settings.username forKey:loginParser.ssnFieldName];
		[dict setValue:settings.password forKey:loginParser.passwordFieldName];
                
		[self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];	
	}
	else {
		self.errorMessage = @"Kunde inte avkoda inloggningsformuläret";
        [delegate loginFailed:self];
	}
	
	[loginParser release];
}

- (void)postLoginSucceeded:(NSURL*)destinationURL responseString:(NSString *)responseString
{
	if ([responseString rangeOfString:@"Logout"].location != NSNotFound || 
        [responseString rangeOfString:@"Logga ut"].location != NSNotFound) {
		[delegate performSelector:@selector(loginSucceeded:) withObject:self];		
	}
    else {
        [delegate performSelector:@selector(loginFailed:) withObject:self];
    }
}

#pragma mark - Request delegates
- (void)postLoginRequestSucceeded:(id)request
{
	if (debugLog != nil) {
		[debugLog appendStep:@"postLoginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
    }
    
    debug_NSLog(@"%@", [request responseString]);
	[self performSelector:@selector(postLoginSucceeded:responseString:) withObject:[request url] withObject:[request responseString]];
}

- (void)loginRequestSucceeded:(id)request
{
	if (debugLog != nil) {
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
    
	debug_NSLog(@"%@", [request responseString]);
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseString] waitUntilDone:NO];
}

#pragma mark - Memory management
- (void)dealloc
{
	[super dealloc];
}

@end
