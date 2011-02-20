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
#import "BankLogin.h"
#import "BankLoginBase.h"

@interface LansforsakringarLogin : BankLoginBase  <BankLogin> {
	NSData *loginResponseData;
	NSString *loginResponse;
	NSURL *loginURL;
}
@property (nonatomic, retain) NSData *loginResponseData;
@property (nonatomic, retain) NSString *loginResponse;
@property (nonatomic, retain) NSURL *loginURL;

-(void)login:(NSString*)identifier;

@end
