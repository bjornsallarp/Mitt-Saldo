//
//  Created by Björn Sållarp on 2010-05-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AccountUpdater.h"
#import "MittSaldoSettings.h"
#import "BankAccount.h"
#import "CoreDataHelper.h"
#import "BankLoginFactory.h"

#import "HandelsbankenAccountParser.h"
#import "SwedbankAccountParser.h"
#import "NordeaAccountParser.h"
#import "ICABankenAccountParser.h"
#import "LansforsakringarAccountParser.h"
#import "SEBAccountParser.h"
#import "IkanoAccountParser.h"




@implementation AccountUpdater
@synthesize managedObjectContext, delegate, bankIdentifier, errorMessage, debugLog;

-(id) initWithDelegateAndContext:(id<AccountUpdaterDelegate, NSObject>)del 
							  context:(NSManagedObjectContext *)managedObjContext;
{
	self = [super init];
	[self setManagedObjectContext:managedObjContext];
	[self setDelegate:del];
	
	return self;
}

-(void)saveDebugInformation
{
	if([MittSaldoSettings isDebugEnabled])
	{
		LogEntry *toStore = (LogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" 
																	  inManagedObjectContext:managedObjectContext];
		
		toStore.Bank = self.bankIdentifier;
		toStore.DateAdded = [NSDate date];
		toStore.Content = debugLog.Content;
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error?
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
	}
}

-(void)fetchAccountBalance
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	
	accountsRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[settings objectForKey:[NSString stringWithFormat:@"%@Accounts",self.bankIdentifier]]]];
	
	// We want to set our user agent so it's not obvious that we are using a custom app to make the requests.
	// Handelsbanken keeps track of the user-agent and if it differs the authentication cookies are invalid 
	[accountsRequest addRequestHeader:@"User-Agent" value:[settings valueForKey:@"WebViewUserAgent"]];
	[accountsRequest setDelegate:self];
	[accountsRequest setDidFailSelector:@selector(fetchAccountBalanceFailed:)];
	[accountsRequest setDidFinishSelector:@selector(fetchAccountBalanceSucceeded:)];
	
	
	
	if(debugLog != nil)
	{
		[debugLog appendStep:@"fetchAccountBalance" logContent:[NSString stringWithFormat:@"URL: %@ \r\nUserAgent: %@", 
																[[accountsRequest url] absoluteString], 
																[settings valueForKey:@"WebViewUserAgent"]]];
	}
	
	[accountsRequest startAsynchronous];

}


-(void)accountsUpdatedError
{
	// Cookie might have exipired etc. Clear and run again with full authentication!
	if(authenticatedUsingCookies)
	{
		if(debugLog != nil)
		{
			[debugLog appendStep:@"accountsUpdatedError" logContent:@"Removing cookies and trying again!"];
		}
		
		[MittSaldoSettings removeCookiesForBank:self.bankIdentifier];
		[loginHelper release];
		self.errorMessage = nil;
		[self retrieveAccounts];
	}
	else 
	{
		if(debugLog != nil)
		{
			[debugLog appendStep:@"accountsUpdatedError" logContent:self.errorMessage];
		}
		
		[self saveDebugInformation];
		[delegate accountsUpdatedError:self];
	}
}

-(void)parseAccountInformation:(NSData*)xmlData
{
	id<AccountParser, NSObject> accountParser = nil;
	
	// Depending on which bank we're retrieving we need different result parsers.
	if([self.bankIdentifier isEqualToString:@"Swedbank"]) 
	{
		accountParser = [[SwedbankAccountParser alloc] initWithContext:managedObjectContext];
	}
	else if([self.bankIdentifier isEqualToString:@"Nordea"])
	{
		accountParser = [[NordeaAccountParser alloc] initWithContext:managedObjectContext];
	}
	else if([self.bankIdentifier isEqualToString:@"Handelsbanken"])
	{
		accountParser = [[HandelsbankenAccountParser alloc]  initWithContext:managedObjectContext];
	}
	else if([self.bankIdentifier isEqualToString:@"ICA"])
	{
		accountParser = [[ICABankenAccountParser alloc] initWithContext:managedObjectContext];
	}
	else if([self.bankIdentifier isEqualToString:@"Länsförsäkringar"])
	{
		accountParser = [[LansforsakringarAccountParser alloc] initWithContext:managedObjectContext];		
	}
    else if([self.bankIdentifier isEqualToString:@"SEB"])
    {
        accountParser = [[SEBAccountParser alloc] initWithContext:managedObjectContext];
    }
    else if ([self.bankIdentifier isEqualToString:@"Ikano"]) {
        accountParser = [[IkanoAccountParser alloc] initWithContext:managedObjectContext];
    }
	
	
	int parsedAccounts = 0;
	NSError *parseError;
	
	if(accountParser)
	{
		// Parse the xml and store the results in our object model
		[accountParser parseXMLData:xmlData parseError:&parseError];
		
		parsedAccounts = accountParser.accountsParsed;
		
		[accountParser release];
	}
	
	if(parsedAccounts > 0)
	{
		[delegate accountsUpdated:self];
	}
	else 
	{
		[self saveDebugInformation];
		[delegate accountsUpdatedError:self];
	}
}

-(void)retrieveAccounts
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSURL *loginUrl = [NSURL URLWithString:[settings objectForKey:[NSString stringWithFormat:@"%@Login", self.bankIdentifier]]];

	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:loginUrl];
		
	// Check to see if we already have cookies. If we do, we don't have to login, unless it's Länsforsakringar
	if([cookies count] <= 0 || [self.bankIdentifier isEqualToString:@"Länsförsäkringar"])
	{
		authenticatedUsingCookies = NO;
		
		loginHelper = [[BankLoginFactory createLoginProxy:self.bankIdentifier] retain];
        
		loginHelper.delegate = self;
		[loginHelper login:self.bankIdentifier];
	}
	else
	{
		authenticatedUsingCookies = YES;
		[self fetchAccountBalance];
	}
}

-(void) retrieveAccounts:(NSString*)aBankIdentifier
{	
	self.bankIdentifier = aBankIdentifier;
	
	[self retrieveAccounts];
}


#pragma mark -
#pragma mark ASIHTTPRequest delegates

-(void)fetchAccountBalanceSucceeded:(ASIHTTPRequest*)request
{
	if(debugLog != nil)
	{
		[debugLog appendStep:@"fetchAccountBalanceSucceeded" logContent:[NSString stringWithFormat:@"URL: %@ \r\n Content: %@", 
																		 [[request url] absoluteString],
																		 [request responseString]]];
	}
    
	// If the request ended up at a different url than the one we initially requested, something has gone wrong
	if(![[[request url] absoluteString] isEqualToString:[[request originalURL] absoluteString]])
	{
		[self performSelectorOnMainThread:@selector(accountsUpdatedError) withObject:nil waitUntilDone:NO];
	}
	else 
	{
        NSMutableString *html = [NSMutableString stringWithString:[request responseString]];
		[html replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&aring;" withString:@"å" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&auml;" withString:@"ä" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&ouml;" withString:@"ö" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&Aring;" withString:@"å" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&Auml;" withString:@"ä" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
   		[html replaceOccurrencesOfString:@"&Ouml;" withString:@"ö" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
        
        
        
		if ([self.bankIdentifier isEqualToString:@"ICA"])
		{
			// ICA isn't XHTML compliant and doesn't return html in UTF8. We need to remove &-chars to successfully parse
			// the html.
            [html replaceOccurrencesOfString:@"&" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
		}
        else if ([self.bankIdentifier isEqualToString:@"Ikano"]) {
            // Correct Ikanos HTML. Unfortunately their HTML doesn't validate because they've put tags inside element attributes
            [html replaceOccurrencesOfString:@"<span>Dina sparkonton</span>" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [html length])];
        }
        
        
        NSData *xmlMarkup = nil;
        if ([self.bankIdentifier isEqualToString:@"Nordea"]) {
            xmlMarkup = [html dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
        }
        else {
            xmlMarkup = [html dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];            
        }
        
		[self performSelectorOnMainThread:@selector(parseAccountInformation:) withObject:xmlMarkup waitUntilDone:NO];
	}
}

-(void)fetchAccountBalanceFailed:(ASIHTTPRequest*)request
{
	self.errorMessage = [request.error localizedDescription];
	[self accountsUpdatedError];
}


-(void)loginSucceeded:(id<BankLogin>)sender
{
	
	if([self.bankIdentifier isEqualToString:@"Länsförsäkringar"])
	{
		// Immediately parse the response because it contains the account info
        if([sender respondsToSelector:@selector(loginResponseData)])
        {
            [self parseAccountInformation:[sender performSelector:@selector(loginResponseData)]];
        }
	}
	else 
	{
		[loginHelper release];
		loginHelper = nil;
		
		// Fetch the balance
		[self fetchAccountBalance];
	}
}

-(void)loginFailed:(id<BankLogin>)sender
{
	self.errorMessage = sender.errorMessage;
	[self accountsUpdatedError];
}

#pragma mark -
#pragma mark Memory management
-(void)dealloc
{
	[debugLog release];
	[accountsRequest release];
	[loginHelper release];
	[errorMessage release];
	[managedObjectContext release];
	[bankIdentifier release];
	
	[super dealloc];
}

@end
