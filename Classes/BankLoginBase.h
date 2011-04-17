//
//  Created by Björn Sållarp on 2010-08-10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "BankLogin.h"
#import "BankSettings.h"
#import "LogEntryClass.h"

@interface BankLoginBase : NSObject 
{
	BankSettings* settings;
	NSString *errorMessage;
	
	id<NSObject, BankLoginDelegate> delegate;
	ASIHTTPRequest *loginRequest;
	ASIFormDataRequest *loginPostRequest;
	LogEntryClass *debugLog;
	
	BOOL wasCancelled;
	
}

@property (nonatomic, retain) BankSettings *settings;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, assign) id<NSObject, BankLoginDelegate> delegate;
@property (nonatomic, readonly) BOOL wasCancelled;
@property (nonatomic, retain) LogEntryClass *debugLog;

-(void)fetchLoginPage:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector;
-(void)postLogin:(id)requestDelegate successSelector:(SEL)successSelector failSelector:(SEL)failSelector postValues:(NSDictionary*)postValues;
-(void)cancelOperation;

@end
