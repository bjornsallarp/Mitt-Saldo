//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "AccountParser.h"

@class NSManagedObjectContext;

@interface ICABankenAccountParser : NSObject<AccountParser> {
	// Flags for parsing HTML
    BOOL isParsingName;
	BOOL isParsingAmount;
	BOOL isParsingAvailableAmount;
}
- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
- (id)initWithContext:(NSManagedObjectContext *)managedObjContext;

@property (nonatomic, assign) int accountsParsed;

@end
