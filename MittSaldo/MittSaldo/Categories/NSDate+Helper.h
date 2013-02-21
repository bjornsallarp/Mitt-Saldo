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

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_Helper)

- (NSUInteger)daysUntilDate:(NSDate *)date;
- (NSUInteger)weekday;

+ (NSDate *)dateAtMidnight:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date alwaysDisplayTime:(BOOL)displayTime;
+ (NSDate *)dateFromDotNetJSONString:(NSString *)string;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;

@end
