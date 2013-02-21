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

#import "NSDate+Helper.h"

static NSCalendar *calendar;
static NSDateFormatter *displayFormatter;
static NSRegularExpression *jsonDateRegEx;

@implementation NSDate (NSDate_Helper)

+ (void)load 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];
    calendar = [[NSCalendar currentCalendar] retain];
    displayFormatter = [[NSDateFormatter alloc] init];
    calendar.locale = displayFormatter.locale = locale;
    
    jsonDateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    [locale release];
	[pool drain];
}

- (NSUInteger)daysUntilDate:(NSDate *)date  
{
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	[mdf release];
    
	return (int)[midnight timeIntervalSinceDate:date] / (60*60*24) *-1;
}

- (NSUInteger)weekday 
{
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSDate *)dateFromString:(NSString *)string 
{
	return [NSDate dateFromString:string withFormat:[NSDate timestampFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format 
{
    displayFormatter.dateFormat = format;
	NSDate *date = [displayFormatter dateFromString:string];
	return date;
}

+ (NSDate *)dateAtMidnight:(NSDate *)date
{
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	return [calendar dateFromComponents:components];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date alwaysDisplayTime:(BOOL)displayTime
{
    /* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
    
	NSDate *today = [NSDate dateAtMidnight:[NSDate date]];
    NSDate *otherDate = [NSDate dateAtMidnight:date];
    
	NSString *displayString = nil;
    
	// comparing against midnight
	if ([today isEqualToDate:otherDate]) {
        // Just return the time
        [displayFormatter setDateFormat:@"'idag' EEEE, 'kl.' HH:mm"]; // 11:30 am
	}
    else {
		// check if date is within last 7 days
        int daysBetweenDates = [today daysUntilDate:otherDate];
        if (daysBetweenDates == 1) {
            [displayFormatter setDateFormat:@"'imorgon' EEEE, 'kl.' HH:mm"]; // 11:30 am    
        }
        else if (daysBetweenDates < 7) {
            if (displayTime)
                [displayFormatter setDateFormat:@"EEEE, 'kl.' HH:mm"]; // Tuesday
            else
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
		} 
        else {
			// check if same calendar year
			NSInteger thisYear = [[calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]] year];
			NSInteger thatYear = [[calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date] year];

			if (thatYear >= thisYear) {
                if (displayTime)
                    [displayFormatter setDateFormat:@"d MMMM, 'kl.' HH:mm"];
                else
                    [displayFormatter setDateFormat:@"d MMMM"];
			} else {
                if (displayTime)
                    [displayFormatter setDateFormat:@"d MMMM yyyy, 'kl.' HH:mm"];
                else
                    [displayFormatter setDateFormat:@"d MMMM yyyy"];
			}
		}
	}
    
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
	return displayString;
}

- (NSString *)stringWithFormat:(NSString *)format 
{
    displayFormatter.dateFormat = format;
    return [displayFormatter stringFromDate:self];
}

- (NSString *)string 
{
	return [self stringWithFormat:[NSDate timestampFormatString]];
}

- (NSDate *)beginningOfWeek 
{
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best    
    NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
						   interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	} 
    
	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	[componentsToSubtract release];
    
	// normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay 
{
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek 
{
    // Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])];
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
	[componentsToAdd release];
    
	return endOfWeek;
}

+ (NSString *)dateFormatString 
{
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString 
{
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString 
{
	return @"yyyy-MM-dd HH:mm:ss";
}

+ (NSDate *)dateFromDotNetJSONString:(NSString *)string
{
    if (!string)
        return nil;
    
    NSTextCheckingResult *regexResult = [jsonDateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult) {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    return nil;
}

@end
