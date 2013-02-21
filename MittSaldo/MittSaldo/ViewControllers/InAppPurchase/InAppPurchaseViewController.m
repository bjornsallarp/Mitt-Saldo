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

#import "InAppPurchaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "InAppPurchaseManager.h"

@implementation InAppPurchaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_navigationBar release];
    [_contentTextView release];
    [_lowPriceButton release];
    [_midPriceButton release];
    [_highPriceButton release];
    [_contentScrollView release];
    
    [super dealloc];
}

+ (InAppPurchaseViewController *)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentTextView.layer.cornerRadius = 5;
    self.contentTextView.layer.borderColor = RGB(144, 144, 144).CGColor;
    self.contentTextView.layer.borderWidth = 1;
    
    [self.highPriceButton setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [self.midPriceButton setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [self.lowPriceButton setBackgroundImage:[[UIImage imageNamed:@"gray_button.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    
    self.navigationBar.topItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Avbryt" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissViewAction:)] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDidComplete) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDidFail) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustInterfaceToOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self isPurchasePossible];
}

- (BOOL)isPurchasePossible
{
    if (![[InAppPurchaseManager sharedManager] canMakePurchases]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InAppPurchaseCannotMakePurchaseTitle", nil)
                                                        message:NSLocalizedString(@"InAppPurchaseCannotMakePurchaseMessage", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    else if (![[InAppPurchaseManager sharedManager] isReadyForPurchase]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InAppPurchaseNotReadyTitle", nil) 
                                                        message:NSLocalizedString(@"InAppPurchaseNotReadyMessage", nil) 
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    
    return YES;
}

- (void)adjustInterfaceToOrientation
{
    if (IDIOM != IPAD) {
        double viewWidth = self.contentScrollView.frame.size.width;
        double contentHight = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 146 : 220;
        double buttonHeight = 44;
        double buttonWidth = viewWidth - 20;
        double buttonYpadding = 8;
        
        self.contentTextView.frame = CGRectMake(10, 10, viewWidth-20, contentHight);
        self.highPriceButton.frame = CGRectMake(10, contentHight+18, buttonWidth, buttonHeight);
        self.midPriceButton.frame = CGRectMake(10,  self.highPriceButton.frame.origin.y + buttonHeight + buttonYpadding, buttonWidth, buttonHeight);
        self.lowPriceButton.frame = CGRectMake(10,  self.midPriceButton.frame.origin.y + buttonHeight + buttonYpadding, buttonWidth, buttonHeight);
        
        self.contentScrollView.contentSize = CGSizeMake(viewWidth, self.lowPriceButton.frame.origin.y+buttonHeight+10);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self adjustInterfaceToOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Notifications

- (void)purchaseDidComplete
{
    self.lowPriceButton.enabled = self.midPriceButton.enabled = self.highPriceButton.enabled = YES;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)purchaseDidFail
{
    self.lowPriceButton.enabled = self.midPriceButton.enabled = self.highPriceButton.enabled = YES;
}

#pragma mark - Actions

- (IBAction)buyLowPriceAction:(id)sender
{
    if ([self isPurchasePossible]) {
        [[InAppPurchaseManager sharedManager] purchaseLowPrice];
        self.lowPriceButton.enabled = self.midPriceButton.enabled = self.highPriceButton.enabled = NO;        
    }
}

- (IBAction)buyMidPriceAction:(id)sender
{
    if ([self isPurchasePossible]) {
        [[InAppPurchaseManager sharedManager] purchaseMidPrice];
        self.lowPriceButton.enabled = self.midPriceButton.enabled = self.highPriceButton.enabled = NO;
    }
}

- (IBAction)buyHighPriceAction:(id)sender
{
    if ([self isPurchasePossible]) {
        [[InAppPurchaseManager sharedManager] purchaseHighPrice];
        self.lowPriceButton.enabled = self.midPriceButton.enabled = self.highPriceButton.enabled = NO;
    }
}

- (IBAction)dismissViewAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"InAppPurchaseView";
}

@end
