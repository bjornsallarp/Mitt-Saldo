//
//  ICABankenTests.m
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "ICABankenTests.h"
#import "ICABankenTestableLogin.h"
#import "ICABankenLoginParser.h"
#import "TestCredentials.h"

@interface ICABankenTests ()
@property (nonatomic, assign) int step;
@end

@implementation ICABankenTests
@synthesize step;

- (void)testLoginPhone
{
    [MSNetworkingClient sharedClient].userAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    
    [ICABankenTestableLogin setupForTests];
    ICABankenTestableLogin *login = [ICABankenTestableLogin icaBankenLoginWithUsername:ICABANKEN_USERNAME andPassword:ICABANKEN_PASSWORD];
    
    __block int status = 0;
    __block NSString *loginErrorMessage = nil;
    
    [login performLoginWithSuccessBlock:^{
        status = 1;
    } failure:^(NSString *errorMessage) {
        loginErrorMessage = errorMessage;
        status = 2;
    }];
    
    while (status == 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    
    if (status == 2) {
        if (login.loginStep == 0) {
            ICABankenLoginParser *parser = [login performSelector:@selector(loginParser)];
            STAssertNotNil(parser.ssnFieldName, @"ssn field is null");
            STAssertNotNil(parser.passwordFieldName, @"password field is null");
        }
        
        STFail(@"Authentication failed for ICABanken with message: %@", loginErrorMessage);
    }
}

- (void)testLoginIPad
{
    [MSNetworkingClient sharedClient].userAgent = @"Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10";
    
    [ICABankenTestableLogin setupForTests];
    
    ICABankenTestableLogin *login = [ICABankenTestableLogin icaBankenLoginWithUsername:ICABANKEN_USERNAME andPassword:ICABANKEN_PASSWORD];
    login.isIPAD = YES;
    
    
    __block int status = 0;
    __block NSString *loginErrorMessage = nil;
    
    [login performLoginWithSuccessBlock:^{
        status = 1;
    } failure:^(NSString *errorMessage) {
        loginErrorMessage = errorMessage;
        status = 2;
    }];
    
    while (status == 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    
    if (status == 2) {
        if (login.loginStep == 0) {
            ICABankenLoginParser *parser = [login performSelector:@selector(loginParser)];
            STAssertNotNil(parser.ssnFieldName, @"ssn field is null");
            STAssertNotNil(parser.passwordFieldName, @"password field is null");
        }
        
        STFail(@"Authentication failed for ICABanken with message: %@", loginErrorMessage);
    }
}

@end
