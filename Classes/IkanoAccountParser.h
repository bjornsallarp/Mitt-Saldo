//
//  IkanoAccountParser.h
//  MittSaldo
//
//  Created by Björn Sållarp on 5/28/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountParser.h"

@class NSManagedObjectContext;

@interface IkanoAccountParser : NSObject<AccountParser> {
    // Flags for parsing HTML
    BOOL isParsingAccounts;
	BOOL isParsingAmount;
}
- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
- (id)initWithContext:(NSManagedObjectContext *)managedObjContext;

@property (nonatomic, assign) int accountsParsed;
@end
