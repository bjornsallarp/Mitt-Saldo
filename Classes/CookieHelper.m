//
//  Created by Björn Sållarp on 2010-06-21.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "CookieHelper.h"

@implementation CookieHelper

+(BOOL)cookieExists:(NSString*)cookieName forUrl:(NSURL*)url
{
	BOOL doesExist = NO;
	
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	
	NSArray* cookies = [cookieStorage cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies) 
	{
		if([[cookie name] isEqualToString:cookieName])
		{
			doesExist = YES;
		}
    }
	
	return doesExist;
}


@end
