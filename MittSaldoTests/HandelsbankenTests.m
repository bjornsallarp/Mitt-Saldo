//
//  HandelsbankenTests.m
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "HandelsbankenTests.h"
#import "HandelsbankenTestableLogin.h"
#import "HandelsbankenMenuParser.h"
#import "TestCredentials.h"

@implementation HandelsbankenTests

- (void)testLoginPhone
{
    [MSNetworkingClient sharedClient].userAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    
    [HandelsbankenTestableLogin setupForTests];
    HandelsbankenTestableLogin *login = [HandelsbankenTestableLogin handelsbankenLoginWithUsername:SHB_USERNAME andPassword:SHB_PASSWORD];
    
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
            HandelsbankenMenuParser *menuParser = [login performSelector:@selector(menuParser)];
            STAssertNotNil(menuParser, @"The menu parser doesn't exist!");
            STAssertEquals([menuParser.menuLinks count], 6U, @"There should be 6 menu links");     
        }
        else if (login.loginStep == 1) {
            HandelsbankenMenuParser *menuParser = [login performSelector:@selector(menuParser)];
            STAssertNotNil(menuParser, @"The menu parser doesn't exist!");
            STAssertEquals([menuParser.menuLinks count], 8U, @"There should be 8 menu links");
        }
        
        STFail(@"Authentication failed for Nordea with message: %@", loginErrorMessage);
    }
    
    HandelsbankenMenuParser *menuParser = [login performSelector:@selector(menuParser)];
    STAssertNotNil(menuParser, @"The menu parser doesn't exist!");
    STAssertEquals([menuParser.menuLinks count], 8U, @"There should be 8 menu links");
}

@end
