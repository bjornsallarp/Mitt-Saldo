//
//  Created by Björn Sållarp on 2011-01-06.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>


@interface LansforsakringarLoginParser : NSObject {
	NSMutableDictionary *hiddenFields;
	BOOL inLoginForm;
}
@property (nonatomic, retain) NSMutableDictionary *hiddenFields;

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;

@end
