//
//  NordeaTestableLogin.h
//  MittSaldo
//
//  Created by  on 12/31/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NordeaLogin.h"

@interface NordeaTestableLogin : NordeaLogin
+ (void)setupForTests;
@property (nonatomic, assign) int loginStep;
@end
