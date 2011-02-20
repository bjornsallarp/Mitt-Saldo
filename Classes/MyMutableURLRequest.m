//
//  Created by Björn Sållarp on 2010-09-19.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//
//  CODE FROM: http://www.icab.de/blog/2010/04/07/changing-the-headers-for-uiwebkit-http-requests/
//

#import "MyMutableURLRequest.h"
#import "Swizzle.h"

@implementation NSMutableURLRequest (MyMutableURLRequest)

- (void)newSetValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
{
    if ([field isEqualToString:@"User-Agent"]) {
        value = @"Mozilla/5.0 (iPad; U; CPU OS 3_2_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B500 Safari/531.21.10";
    }
    [self newSetValue:value forHTTPHeaderField:field];
}

+ (void)setupUserAgentOverwrite
{    
    [self swizzleMethod:@selector(setValue:forHTTPHeaderField:)
			 withMethod:@selector(newSetValue:forHTTPHeaderField:)];
}

@end
