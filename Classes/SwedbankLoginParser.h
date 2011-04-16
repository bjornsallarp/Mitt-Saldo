//
//  Created by Björn Sållarp on 2011-04-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>

@protocol NSXMLParserDelegate;
@interface SwedbankLoginParser : NSObject<NSXMLParserDelegate> {
	NSString *csrf_token;
	NSString *usernameField;
	NSString *passwordField;
    NSString *nextLoginStepUrl;
}

@property (nonatomic, retain) NSString *csrf_token;
@property (nonatomic, retain) NSString *usernameField;
@property (nonatomic, retain) NSString *passwordField;
@property (nonatomic, retain) NSString *nextLoginStepUrl;

-(BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error;

@end
