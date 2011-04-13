//
//  SwedbankLogin.m
//  MittSaldo
//
//  Created by Björn Sållarp on 4/12/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "SwedbankLogin.h"
#import "MittSaldoSettings.h"
#import "SwedbankLoginParser.h"

@interface SwedbankLogin ()
@property (nonatomic, retain) SwedbankLoginParser *loginParser;
@end

@implementation SwedbankLogin
@synthesize loginParser;
@dynamic delegate, errorMessage, wasCancelled, settings, debugLog;

-(void)login:(NSString*)identifier
{
	self.settings = [MittSaldoSettings settingsForBank:identifier];
    
    // Swedbank has a two-step authentication. We use the same parser for both
    self.loginParser = [[[SwedbankLoginParser alloc] init] autorelease];
    loginStep = 1;
    
	[self fetchLoginPage:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:)];
}

#pragma mark -
#pragma mark Response parsing methods

-(void)parseLoginPage:(NSData*)data
{
	[data retain];
	
	// First we need to parse the menu because the login page change URL over time
	NSError *error = nil;
	
	if([loginParser parseXMLData:data parseError:&error])
	{
		if(loginParser.csrf_token == nil || [loginParser.csrf_token isEqualToString:@""])
		{
			self.errorMessage = @"Kunde inte avkoda inloggningsformuläret";
		}
	}
	
	[data release];
	
	if(self.errorMessage == nil) {

        // We always expec a csrf token and a username field to be parsed
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:settings.username forKey:loginParser.usernameField];
        [dict setValue:loginParser.csrf_token forKey:@"_csrf_token"];
        
        if (loginStep == 1) {
            
            // Use personal code, not digipass
            [dict setValue:@"code" forKey:@"auth-method"];
            
            // Update the URL we're posting to, the login sequence is multiple steps
            self.settings.loginURL = [NSURL URLWithString:loginParser.nextLoginStepUrl relativeToURL:self.settings.loginURL];
            
            debug_NSLog(@"First step, posting to: %@. Usernamefield: %@. csrf_token: %@", [self.settings.loginURL absoluteString], loginParser.usernameField, loginParser.csrf_token);
            
            // Move on to the next step
            loginStep++;
            
            // Post for first step authentication, we use the same success selector so that a successfull post ends up back here again 
            [self postLogin:self successSelector:@selector(loginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];
        }
        else if(loginStep == 2) 
        {
            // Update the login url, it has changed again for the seconds step
            self.settings.loginURL = [NSURL URLWithString:loginParser.nextLoginStepUrl relativeToURL:self.settings.loginURL];
            
            // Add the password field. We got this from the first step. The csrf and username is added above.
            [dict setValue:settings.password forKey:loginParser.passwordField];
            debug_NSLog(@"Second step, posting to: %@. Usernamefield: %@. PasswordField: %@. csrf_token: %@", 
                        [self.settings.loginURL absoluteString], loginParser.usernameField, loginParser.passwordField, loginParser.csrf_token);
            
            [self postLogin:self successSelector:@selector(postLoginRequestSucceeded:) failSelector:@selector(requestFailed:) postValues:dict];
        }
    }
	else if(delegate)
	{
		[delegate loginFailed:self];
	}
}


-(void)postLoginSucceeded:(NSString*)recievedPage
{
    // Check if the page has a csrf token, if so, it's likely we're back at a login page
	if([recievedPage rangeOfString:@"_csrf_token"].length > 0)
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
	
	[self performSelectorOnMainThread:@selector(postLoginSucceeded:) withObject:[request responseString] waitUntilDone:NO];
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
    [loginParser release];
	[super dealloc];
}

@end
