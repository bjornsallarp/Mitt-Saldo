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

#import "SmartbudgetViewController.h"

@implementation SmartbudgetViewController

- (void)dealloc
{
    [_registerButton release];
    [_contentScrollView release];
    [_contentTextView release];
    [_logoBgView release];
    [super dealloc];
}

+ (id)controller
{
    return [[[self alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Smartbudget";
    
    self.logoBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header_bg.png"]];
    
    if (IDIOM == IPAD) {
        self.contentTextView.font = [UIFont systemFontOfSize:16];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    self.contentScrollView.contentOffset = CGPointMake(0, 0);
    self.contentScrollView.scrollEnabled = NO;
    self.contentScrollView.contentSize = self.contentScrollView.bounds.size;

    CGRect registerFrame = self.registerButton.frame;
    registerFrame.origin.y = self.contentTextView.frame.size.height + self.contentTextView.frame.origin.y;
    self.registerButton.frame = registerFrame;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.registerButton.frame = CGRectOffset(self.registerButton.frame, 0, -40);
        
        self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.bounds.size.width, self.registerButton.frame.origin.y + self.registerButton.bounds.size.height + 30);
        self.contentScrollView.scrollEnabled = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (IBAction)registerAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.smartbudget.se/registrera"]];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"SmartBudgetView";
}

@end
