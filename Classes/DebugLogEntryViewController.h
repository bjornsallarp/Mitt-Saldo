//
//  DebugLogEntryViewController.h
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LogEntry.h"

@interface DebugLogEntryViewController : UIViewController<MFMailComposeViewControllerDelegate> {
	IBOutlet UILabel *bankLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UIWebView *debugContentWebView;
	
	LogEntry *debugLogEntry;
}

-(IBAction) emailLogEntry:(id)sender;

@property (nonatomic, retain) LogEntry *debugLogEntry;


@end
