//
//  Created by Björn Sållarp on 2010-06-06.
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

@interface NordeaAccountParser : NSObject<AccountParser> {
	BOOL isParsingAccounts;
	BOOL isParsingAccount;
	BOOL isParsingAmount;
	
	
	BankAccount *currentAccount;
	NSManagedObjectContext *managedObjectContext;
	
	NSMutableString *contentsOfCurrentProperty;
	int accountsParsed;
}
-(BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
-(id) initWithContext: (NSManagedObjectContext *) managedObjContext;

@property (nonatomic, retain) NSMutableString *contentsOfCurrentProperty;
@property (nonatomic, assign) int accountsParsed;
@end
