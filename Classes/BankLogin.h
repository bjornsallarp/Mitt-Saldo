//
//  Created by Björn Sållarp on 2010-06-21.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "BankSettings.h"
#import "LogEntryClass.h"

@protocol BankLogin<NSObject>
@required
-(void)cancelOperation;
-(void)login:(NSString*)identifier;
@property (nonatomic, retain) NSString *errorMessage;
@property (nonatomic, assign) id<NSObject> delegate;
@property (nonatomic, retain) BankSettings *settings;
@property (nonatomic, readonly) BOOL wasCancelled;
@property (nonatomic, retain) LogEntryClass *debugLog;
@end

@protocol BankLoginDelegate<NSObject>
@required
-(void)loginSucceeded:(id<BankLogin>)sender;
-(void)loginFailed:(id<BankLogin>)sender;
@end