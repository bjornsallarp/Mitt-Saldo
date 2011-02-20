//
//  Created by Björn Sållarp on 2010-06-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "AboutMittSaldoViewController.h"


@implementation AboutMittSaldoViewController
@synthesize webView, topToolbar;
@synthesize backButton, aboutButton, stopButton, errorReportButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.webView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
	self.backButton.enabled = [webView canGoBack];
	[self aboutButtonClick:nil];
}

#pragma mark -
#pragma mark Toolbar button events
/*
	Events are bound through IB
*/

-(IBAction)stopButtonClick:(id)sender
{
	[self.webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(IBAction)backButtonClick:(id)sender
{
	[self.webView goBack];
}

-(IBAction)aboutButtonClick:(id)sender
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path isDirectory:NO]]];
}

-(IBAction)errorReportButtonClick:(id)sender
{
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://blog.sallarp.com/mitt-saldo-felrapport"]]];
}

#pragma mark -
#pragma mark UIWebView delegate methods

-(BOOL)webView:(UIWebView *)browser shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)browser
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.backButton.enabled = [webView canGoBack];
	self.stopButton.enabled = NO;
}


-(void)webViewDidStartLoad:(UIWebView *)browser
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	self.stopButton.enabled = YES;
}

#pragma mark -
#pragma mark Memmory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[webView release];
	[topToolbar release];
	[backButton release];
	[aboutButton release];
	[stopButton release]; 
	[errorReportButton release];
    [super dealloc];
}


@end
