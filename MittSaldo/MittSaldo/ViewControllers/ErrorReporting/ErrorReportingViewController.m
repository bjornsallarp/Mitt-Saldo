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

#import "ErrorReportingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KundoViewController.h"
#import "MSLNetworkingClient.h"
#import "JSONKit.h"

@interface ErrorReportingViewController ()
- (void)adjustInterfaceToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
@end

@implementation ErrorReportingViewController

- (void)dealloc
{
    [_problemLabel release];
    [_errorReportingButton release];
    [_infoTextView release];
    [_statusTextView release];
    [super dealloc];
}

+ (ErrorReportingViewController *)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Felrapportera";
    [self.errorReportingButton setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    self.infoTextView.layer.cornerRadius = self.statusTextView.layer.cornerRadius = 5;
    self.infoTextView.layer.borderColor = self.statusTextView.layer.borderColor = RGB(144, 144, 144).CGColor;
    self.infoTextView.layer.borderWidth = self.statusTextView.layer.borderWidth = 1;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.statusTextView.text = @"Hämtar statusinformation...";
    self.statusTextView.textAlignment = UITextAlignmentCenter;
    
    [[MSLNetworkingClient sharedClient] getRequestWithURL:[NSURL URLWithString:@"https://raw.github.com/gist/2401052"] cookieStorage:nil completionBlock:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
        if ([requestOperation hasAcceptableStatusCode]) {
            self.statusTextView.textAlignment = UITextAlignmentLeft;
            
            NSDictionary *errorDict = [requestOperation.responseString objectFromJSONString];
            if (errorDict) {
                self.statusTextView.text = [errorDict valueForKey:@"message"];
                self.statusTextView.textColor = [UIColor redColor];
            }
            else {
                self.statusTextView.text = requestOperation.responseString;
                self.statusTextView.textColor = [UIColor blackColor];
            }
        }
    }];
    
    [self adjustInterfaceToOrientation:self.interfaceOrientation];
}

- (void)adjustInterfaceToOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (IDIOM != IPAD) {
        float viewWidth = self.view.bounds.size.width;
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            self.infoTextView.frame = CGRectMake(10, 10, viewWidth - 20, 200);
            self.problemLabel.frame = CGRectMake(20, 225, viewWidth - 30, 20);
            self.statusTextView.frame = CGRectMake(10, 258, viewWidth - 20, 78);
            self.errorReportingButton.frame = CGRectMake(10, 360, viewWidth - 20, 44);
        }
        else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.infoTextView.frame = CGRectMake(10, 10, viewWidth - 20, 100);
            self.problemLabel.frame = CGRectMake(20, 120, viewWidth - 30, 20);
            self.statusTextView.frame = CGRectMake(10, 153, viewWidth - 20, 45);
            self.errorReportingButton.frame = CGRectMake(10, 210, viewWidth - 20, 44);
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustInterfaceToOrientation:self.interfaceOrientation];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)openErrorReportingAction:(id)sender
{
    [KundoViewController presentFromViewController:self.view.window.rootViewController userEmail:nil userName:nil];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"ErrorReportingView";
}

@end
