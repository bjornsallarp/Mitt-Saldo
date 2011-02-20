//
//  Created by Björn Sållarp on 2011-01-20.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "BankAccount.h"
#import "CoreDataHelper.h"
#import "AccountParser.h"

@interface LansforsakringarAccountParser : NSObject<AccountParser> {

	// Flags for parsing HTML
	BOOL isParsingPayAccounts;
	BOOL isParsingSavingsAccounts;
	BOOL isParsingAccount;
	BOOL isParsingAmount;
	
	BankAccount *currentAccount;
	NSManagedObjectContext *managedObjectContext;
	
	NSMutableString *contentsOfCurrentProperty;
	int accountsParsed;
	int savingsAccountsParsed;
}
-(BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
-(id) initWithContext: (NSManagedObjectContext *) managedObjContext;

@property (nonatomic, retain) NSMutableString *contentsOfCurrentProperty;
@property (nonatomic, assign) int accountsParsed;

@end
