//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//

#import "NSString+Helper.h"

@implementation NSString (NSString_Helper)

+ (BOOL)stringIsNullEmpty:(NSString *)string
{
    if (string && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

@end
