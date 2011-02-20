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
@synthesize appDelegate, titleLabel, headerText;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil headerText:(NSString*)text
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		if(text == nil)
		{
			self.headerText = NSLocalizedString(@"UnlockApplication", nil);
		}
		else 
		{
			self.headerText = text;
		}


    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	BSKeyLock *lock = [[BSKeyLock alloc] initWithFrame:CGRectMake(0, 70, 320, 295)];
	lock.delegate = appDelegate;
	[lock setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"keylockbg.png"]]];
	[self.view addSubview:lock];
	[lock release];
	
	
	self.titleLabel.text = self.headerText;
}

#pragma mark -
#pragma mark Memory management
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
	[headerText release];
	[titleLabel release];
	[keyLockImage release];
    [super dealloc];
}


@end
