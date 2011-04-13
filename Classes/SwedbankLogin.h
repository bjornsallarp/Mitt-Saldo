//
//  SwedbankLogin.h
//  MittSaldo
//
//  Created by Björn Sållarp on 4/12/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
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
