//
//  HandelsbankenTestableLogin.m
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "HandelsbankenTestableLogin.h"
#import "Swizzle.h"

@implementation HandelsbankenTestableLogin
@synthesize loginStep;

+ (void)setupForTests
{
    [self swizzleMethod:@selector(loginStepTwo:) withMethod:@selector(newLoginStepTwo:)];
}

- (void)newLoginStepTwo
{
    loginStep++;
    [self newLoginStepTwo];
}


@end
