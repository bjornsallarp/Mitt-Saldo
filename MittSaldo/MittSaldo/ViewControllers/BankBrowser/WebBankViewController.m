//
//  Created by Björn Sållarp on 2010-05-23.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "WebBankViewController.h"
#import "MSConfiguredBank+Helper.h"
#import "NSManagedObjectContext+MSHelper.h"
#import "MSLServicesFactory.h"
#import "MSLServiceProxyBase.h"

static const int kBookmarkConfirmationAlert = 1;

@interface WebBankViewController()
@property (nonatomic, retain) MSConfiguredBank *bank;
@property (nonatomic, retain) UIBarButtonItem *bookmarkButton;
@end

@implementation WebBankViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_webBrowser release];
    [_browserUrlLabel release];
    [_browserActivityIndicator release];
    [_bookmarkButton release];
    [_bank release];
    [super dealloc];
}

+ (id)controllerForBank:(MSConfiguredBank *)bank
{
    WebBankViewController *controller = [[self alloc] initWithNibName:nil bundle:nil];
    controller.bank = bank;

    return [controller autorelease];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

	self.webBrowser.delegate = self;
    self.title = self.bank.name;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self authenticateWithBank];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)authenticateWithBank
{    
	[self.browserActivityIndicator startAnimating];
	self.browserUrlLabel.text = NSLocalizedString(@"Authenticating", nil);
	self.navigationItem.rightBarButtonItem = nil;
    
    self.bookmarkButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn-bookmark.png"] 
                                                            style:UIBarButtonItemStyleBordered 
                                                           target:self 
                                                           action:@selector(bookmarkPage:)] autorelease];
    
    __block MSLServiceProxyBase *login = [MSLServicesFactory proxyForServiceWithIdentifier:self.bank.bankIdentifier];
    login.username = self.bank.ssn;
    login.password = self.bank.password;

    [login performLoginWithSuccessBlock:^{
        
        [self.browserActivityIndicator stopAnimating];
       
        // Empty cookies
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* cookies = [cookieStorage cookiesForURL:login.loginURL];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        // load our new authenticated cookies. Yum yum!
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:login.cookieStorage forURL:login.loginURL mainDocumentURL:nil];
        
        if ([login respondsToSelector:@selector(loadLoginIntoBrowser:)]) {
            [login performSelector:@selector(loadLoginIntoBrowser:) withObject:self.webBrowser];
        }
        else {
            NSURL *startPageURL = self.bank.bookmarkURL ? self.bank.bookmarkURL : login.transferFundsURL;
            [self.webBrowser loadRequest:[NSURLRequest requestWithURL:startPageURL]];            
        }
    } failure:^(NSError *error, NSString *errorMessage) {
        
        [self.browserActivityIndicator startAnimating];
        
        NSString *title = nil;
        NSString *alertMessage = nil;
        NSString *otherButtonTitle = nil;
        id delegate = nil;
        
        
        if (error) {
            if (error.code == NSURLErrorTimedOut) {
                title = @"Timeout";
                alertMessage = @"Banken har inte svarat på anrop. Det kan bero på att deras tjänst är ur funktion eller att din anslutning inte fungerar optimalt.";
            }
            else {
                title = @"Anslutningsproblem";
                alertMessage = [error localizedDescription];    
            }
        }
        else {
            title = NSLocalizedString(@"AccountUpdateErrorMessageTitle", nil);
            alertMessage = NSLocalizedString(errorMessage, errorMessage);
            otherButtonTitle = NSLocalizedString(@"ReportError", nil);
            delegate = self;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:alertMessage
                                                       delegate:delegate 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:otherButtonTitle, nil];
        
        alert.tag = delegate ? 999 : 0;
        [alert show];
        [alert release];
    }];
}

#pragma mark - UI Events

- (IBAction)bookmarkPage:(id)sender
{
    UIAlertView *bookmarkAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WebBankBookmarkAlertTitle", nil)
                                                            message:NSLocalizedString(@"WebBankBookmarkAlertMessage", nil) 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"No", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    bookmarkAlert.tag = kBookmarkConfirmationAlert;
    [bookmarkAlert show];
    [bookmarkAlert release];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kBookmarkConfirmationAlert) {
        if (buttonIndex == 1) {
            self.bank.bookmarkURL = [NSURL URLWithString:self.browserUrlLabel.text];
            [NSManagedObjectContext saveAndAlertOnError];
        }
    }
}

#pragma mark - Web view delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	self.browserUrlLabel.text = [[request URL] absoluteString];	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.browserActivityIndicator stopAnimating];
    
    if (![self.bank.bankIdentifier isEqualToString:@"Länsförsäkringar"]) {
        self.navigationItem.rightBarButtonItem = self.bookmarkButton;
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.browserActivityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Accessor

- (NSString *)nibName
{
    return @"WebBankView";
}

@end
