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
#import "KundoViewController.h"

@implementation AboutMittSaldoViewController
@synthesize webView = _webView;

- (void)viewDidLoad 
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path isDirectory:NO]]];
}

#pragma mark - UI Events

- (IBAction)errorReportButtonClick:(id)sender
{
    [KundoViewController presentFromViewController:self userEmail:nil userName:nil];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
	[_webView release];
    [super dealloc];
}

@end
