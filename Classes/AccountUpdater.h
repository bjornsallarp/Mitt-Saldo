//
//  Created by Björn Sållarp on 2010-05-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#import "BankLogin.h"
#import "LogEntry.h"
#import "LogEntryClass.h"

@protocol AccountUpdaterDelegate<NSObject>
@required
-(void)accountsUpdated:(id)sender;
-(void)accountsUpdatedError:(id)sender;
@end


@interface AccountUpdater : NSObject<BankLoginDelegate> {
	NSManagedObjectContext *managedObjectContext;
	id<AccountUpdaterDelegate, NSObject> delegate;
	id<BankLogin, NSObject> loginHelper;
	NSString *bankIdentifier;
	NSString *errorMessage;
	ASIHTTPRequest *accountsRequest;
	BOOL authenticatedUsingCookies;
	LogEntryClass *debugLog;
	
}
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) NSString *bankIdentifier;
@property (retain, nonatomic) NSString *errorMessage;
@property (assign) id<AccountUpdaterDelegate, NSObject> delegate;
@property (retain, nonatomic) LogEntryClass *debugLog;

-(id) initWithDelegateAndContext:(id<AccountUpdaterDelegate, NSObject>)del 
						 context:(NSManagedObjectContext *)managedObjContext;

-(void) retrieveAccounts:(NSString*)aBankIdentifier;
-(void) retrieveAccounts;

@end


