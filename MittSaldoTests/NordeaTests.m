//
//  NordeaTests.m
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "NordeaTests.h"
#import "NordeaTestableLogin.h"
#import "NordeaLoginParser.h"
#import "TestCredentials.h"

@implementation NordeaTests

- (void)testLoginPhone
{
    [MSNetworkingClient sharedClient].userAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    
    [NordeaTestableLogin setupForTests];
    NordeaTestableLogin *login = [NordeaTestableLogin nordeaLoginWithUsername:NORDEA_USERNAME andPassword:NORDEA_PASSWORD];
    
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
            NordeaLoginParser *loginParser = [login performSelector:@selector(loginParser)];
            STAssertNotNil(loginParser.csrf_token, @"A csrf token should have been parsed");
            STAssertNotNil(loginParser.usernameField, @"A username field id should have been parsed");
            STAssertNotNil(loginParser.passwordField, @"A username field id should have been parsed");      
        }
        
        STFail(@"Authentication failed for Nordea with message: %@", loginErrorMessage);
    }
}

@end
