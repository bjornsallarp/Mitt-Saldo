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
#import "BankLogin.h"
#import "BankLoginBase.h"

@class SwedbankLoginParser;

@interface SwedbankLogin : BankLoginBase <BankLogin> {
    SwedbankLoginParser *loginParser;
    NSUInteger loginStep;
}

-(void)login:(NSString*)identifier;

@end
