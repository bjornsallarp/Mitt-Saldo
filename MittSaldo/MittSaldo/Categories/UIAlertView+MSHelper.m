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

#import "UIAlertView+MSHelper.h"
#import "MSConfiguredBank.h"

const int kErrorReportingAlertTag = 100100;

@implementation UIAlertView (MSHelper)

+ (void)showUpdateDidFailAlertForBank:(MSConfiguredBank *)failedBank error:(NSError *)error message:(NSString *)message errorReportingDelegate:(id)errorReportingDelegate
{
    NSString *alertMessage = nil;
    NSString *title = @""; 
    NSString *otherButtonTitle = nil;
    id alertDelegate = nil;
    
    if (error) {
        if (error.code == NSURLErrorTimedOut) {
            title = @"Timeout";
            alertMessage = [NSString stringWithFormat:@"%@ har inte svarat på anrop. Det kan bero på att deras tjänst är ur funktion eller att din anslutning inte fungerar optimalt.", failedBank.name];
        } else {
            title = @"Anslutningsproblem";
            alertMessage = [error localizedDescription];    
        }
    }
    else if (message) {
        title = failedBank.name;
        alertMessage = NSLocalizedString(message, message);
        
        if (![alertMessage isEqualToString:message]) {
            alertDelegate = errorReportingDelegate;
            otherButtonTitle = NSLocalizedString(@"ReportError", nil);
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:alertMessage
                                                   delegate:alertDelegate 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:otherButtonTitle, nil];
    
    if (otherButtonTitle) {
        alert.tag = kErrorReportingAlertTag;
    }
    
    [alert show];
    [alert release];      
}

@end
