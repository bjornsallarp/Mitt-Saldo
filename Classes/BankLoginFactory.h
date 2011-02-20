//
//  Created by Björn Sållarp on 2011-02-12.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import "BankLogin.h"

@interface BankLoginFactory : NSObject {
    
}

+(id<BankLogin, NSObject>)createLoginProxy:(NSString*)bankIdentifier;

@end
