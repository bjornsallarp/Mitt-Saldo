//
//  DebugLogEntryViewController.m
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DebugLogEntryViewController.h"

#import "MLUtils.h"


@implementation DebugLogEntryViewController
@synthesize debugLogEntry;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 
	bankLabel.text = debugLogEntry.Bank;
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
		
	dateLabel.text = [dateFormatter stringFromDate:debugLogEntry.DateAdded];

	[debugContentWebView loadHTMLString:[NSString stringWithFormat:@"<html><body>%@</body></html>", [debugLogEntry.Content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]]
								baseURL:[NSURL URLWithString:@"http://localhost"]];
}


-(IBAction) emailLogEntry:(id)sender
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Debuginformation - Mitt saldo"];
	[picker setMessageBody:debugLogEntry.Content isHTML:NO]; 	
	picker.navigationBar.barStyle = UIBarStyleBlack; 
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
	if(result == MFMailComposeResultFailed)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CannotSendEMail", nil)
														message:[error localizedDescription]
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil];
		

		
		[alert show];
		[alert release];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[debugLogEntry release];
	
	// Outlets
	[bankLabel release];
	[dateLabel release];
	[debugContentWebView release];
	
    [super dealloc];
}


@end
