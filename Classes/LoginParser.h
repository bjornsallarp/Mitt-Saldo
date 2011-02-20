//
//  Created by Björn Sållarp on 2010-05-02.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "BankLoginBase.h"

@interface LoginParser : BankLoginBase <BankLogin> {

	NSString *csrf_token;
	NSString *usernameField;
	NSString *passwordField;
}

@property (nonatomic, retain) NSString *csrf_token;
@property (nonatomic, retain) NSString *usernameField;
@property (nonatomic, retain) NSString *passwordField;


-(BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error;
-(void)login:(NSString*)identifier;

@end
