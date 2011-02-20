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

#import <Foundation/Foundation.h>


@interface NSMutableURLRequest (MyMutableURLRequest)

+ (void)setupUserAgentOverwrite;

@end
