//
//  SwedbankLogin+Testable.m
//  MittSaldo
//
//  Created by  on 12/7/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "SwedbankTestableLogin.h"
#import "Swizzle.h"

@implementation SwedbankTestableLogin
@synthesize loginStep;

+ (void)setupForTests
{
    [self swizzleMethod:@selector(loginStepTwo) withMethod:@selector(newLoginStepTwo)];
    [self swizzleMethod:@selector(loginStepThree) withMethod:@selector(newLoginStepThree)];    
}

- (void)newLoginStepTwo
{
    loginStep++;
    [self newLoginStepTwo];
}

- (void)newLoginStepThree
{
    loginStep++;
    [self newLoginStepThree];
}

@end
