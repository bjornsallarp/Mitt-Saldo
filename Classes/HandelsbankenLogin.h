//
//  Created by Björn Sållarp on 2010-06-21.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "HandelsbankenMenuParser.h"
#import "BankLogin.h"
#import "BankLoginBase.h"

@interface HandelsbankenLogin : BankLoginBase <BankLogin> {

}

-(void)login:(NSString*)identifier;

@end
