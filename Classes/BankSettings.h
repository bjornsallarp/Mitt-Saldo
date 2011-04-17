//
//  Created by Björn Sållarp on 2010-08-10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>


@interface AccountSettings : NSObject {
	NSString *bankIdentifier;
	NSString *username;
	NSString *password;
	NSURL *loginURL;
	int requestTimeout;
}

@property (nonatomic, retain) NSString *bankIdentifier;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSURL *loginURL;
@property (nonatomic, assign) int requestTimeout;

@end
