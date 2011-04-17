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

- (void)login:(NSString*)identifier;
{
	self.settings = [BankSettings settingsForBank:identifier];
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

- (void)parseLoginPage:(NSString*)reponseString
{
	// The response is HTML, not XHTML. In order for the parser not to choke we simply remove the &-characters
	NSString *fixedMarkup = [reponseString stringByReplacingOccurrencesOfString:@"&" withString:@""];
	
	ICABankenLoginParser *loginParser = [[ICABankenLoginParser alloc] init];
	NSError *error = nil;
	
	if ([loginParser parseXMLData:[fixedMarkup dataUsingEncoding:NSUTF8StringEncoding] parseError:&error]) {
        // Add all the hidden fields we parsed from the login-page
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:loginParser.hiddenFields];
		[dict setValue:settings.username forKey:loginParser.ssnFieldName];
		[dict setValue:settings.password forKey:loginParser.passwordFieldName];
        
        // Do we support javascript? Of course we do!
        [dict setValue:@"1" forKey:@"JSEnabled"];
        
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
	// ICA Banken moves the user to a new page if login succeded, if we are still on the login
	// page after posting successfully the login failed
	if ([[destinationURL absoluteString] isEqualToString:[settings.loginURL absoluteString]]) {
        
        if ([responseString rangeOfString:@"två aktiva sessioner"].location == NSNotFound) {
            [delegate performSelector:@selector(loginFailed:) withObject:self];
        }
        else {
            // if we got the error message about two active sessions the login actually worked but a session was 
            // already active, so we were instead logged out. This can happen if you're logged in with your PC but
            // is most likely to happen if you use the app, close it (cookies cleared), open it and authenticate.
            // We know the authentication was actually correct when we get this message, so we rewind and authenticate agan.
            // The flag is there to make sure we don't end up in a crazy loop. The chance is slim but better safe than sorry, right?
            if (!authenticationRetry) {
                authenticationRetry = YES;
                [self login:settings.bankIdentifier];
            }
            else {
                [delegate performSelector:@selector(loginSucceeded:) withObject:self];
            }
        }
	}
	else {
		[delegate performSelector:@selector(loginSucceeded:) withObject:self];		
	}
}

#pragma mark - Request delegates
- (void)postLoginRequestSucceeded:(id)request
{
	if (debugLog != nil) {
		[debugLog appendStep:@"postLoginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}

	[self performSelector:@selector(postLoginSucceeded:responseString:) withObject:[request url] withObject:[request responseString]];
}

- (void)loginRequestSucceeded:(id)request
{
	if (debugLog != nil) {
		[debugLog appendStep:@"loginRequestSucceeded" logContent:[NSString stringWithFormat:@"URL: %@\r\nContent: %@", [[request url] absoluteString], [request responseString]]];
	}
	
	[self performSelectorOnMainThread:@selector(parseLoginPage:) withObject:[request responseString] waitUntilDone:NO];
}

#pragma mark - Memory management
- (void)dealloc
{
	[super dealloc];
}

@end
