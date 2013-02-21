//
//  SwedbankLogin+Testable.h
//  MittSaldo
//
//  Created by  on 12/7/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwedbankLogin.h"

@interface SwedbankTestableLogin : SwedbankLogin
+ (void)setupForTests;
@property (nonatomic, assign) int loginStep;
@end
