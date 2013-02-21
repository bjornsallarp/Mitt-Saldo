//
//  Created by Björn Sållarp on 2010-05-24.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "KeyLockViewController.h"
#import "BSKeyLock.h"

@implementation KeyLockViewController

- (void)dealloc 
{
	[_headerText release];
	[_titleLabel release];
	[_keyLockImage release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil headerText:(NSString*)text
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.headerText = text ? text : NSLocalizedString(@"UnlockApplication", nil);
	}
    
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

	BSKeyLock *lock = [[BSKeyLock alloc] initWithFrame:CGRectMake(0, 70, 320, 295)];
	lock.delegate = self.appDelegate;
    lock.backgroundColor = [UIColor clearColor];
    lock.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self.view addSubview:lock];
	[lock release];
		
	self.titleLabel.text = self.headerText;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-bg.png"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"KeyLockViewController";
}

@end
