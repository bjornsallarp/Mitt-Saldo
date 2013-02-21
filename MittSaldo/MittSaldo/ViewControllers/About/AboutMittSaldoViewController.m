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
#import <QuartzCore/QuartzCore.h>

@implementation AboutMittSaldoViewController

- (void)dealloc 
{
	[_infoTextView release];
    [super dealloc];
}

+ (id)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Felrapportera" style:UIBarButtonItemStyleBordered target:self action:@selector(errorReportButtonClick:)] autorelease];
    
    self.title = @"Mitt Saldo";
    
    self.infoTextView.layer.cornerRadius =  5;
    self.infoTextView.layer.borderColor = RGB(144, 144, 144).CGColor;
    self.infoTextView.layer.borderWidth = 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)errorReportButtonClick:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MS-NavigateTo" object:self userInfo:[NSDictionary dictionaryWithObject:@"errorReporting" forKey:@"view"]];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AboutMittSaldo";
}

@end
