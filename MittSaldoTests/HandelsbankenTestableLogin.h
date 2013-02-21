//
//  HandelsbankenTestableLogin.h
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HandelsbankenLogin.h"

@interface HandelsbankenTestableLogin : HandelsbankenLogin
+ (void)setupForTests;
@property (nonatomic, assign) int loginStep;
@end
