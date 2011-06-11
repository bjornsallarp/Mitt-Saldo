//
//  IKANOLogin.h
//  MittSaldo
//
//  Created by Björn Sållarp on 5/26/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankLogin.h"
#import "IkanoLoginParser.h"
#import "BankLoginBase.h"

@interface IkanoLogin : BankLoginBase  <BankLogin> 
- (void)login:(NSString*)identifier;
@end
