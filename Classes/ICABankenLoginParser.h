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
@protocol NSXMLParserDelegate;

@interface ICABankenLoginParser : NSObject<NSXMLParserDelegate> 

@property (nonatomic, retain) NSMutableDictionary *hiddenFields;
@property (nonatomic, retain) NSString *ssnFieldName;
@property (nonatomic, retain) NSString *passwordFieldName;

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;

@end
