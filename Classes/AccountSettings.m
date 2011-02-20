//
//  Created by Björn Sållarp on 2010-09-19.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AccountSettings.h"


@implementation AccountSettings
@synthesize bankIdentifier, username, password, loginURL, requestTimeout;


-(void)dealloc
{
	[bankIdentifier release];
	[username release];
	[password release];
	[loginURL release];
    
	[super dealloc];
}
@end
