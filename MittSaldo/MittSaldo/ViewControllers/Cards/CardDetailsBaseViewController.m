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

#import "CardDetailsBaseViewController.h"
#import "MSConfiguredBank.h"
#import "ICACArdDetailsViewController.h"
#import "TicketRikskortetDetailsViewController.h"
#import "CoopCardDetailsViewController.h"
#import "VasttrafikDetailsViewController.h"
#import "SkanetrafikenDetailsViewController.h"

@implementation CardDetailsBaseViewController

- (void)dealloc
{   
    [_configuredCard release];
     [super dealloc];
}

+ (CardDetailsBaseViewController *)controllerForCard:(MSConfiguredBank *)card
{
    if ([card.bankIdentifier isEqualToString:@"Rikskortet"]) {
        return [TicketRikskortetDetailsViewController controllerWithCard:card];
    }
    else if ([card.bankIdentifier isEqualToString:@"ICA Kortet"]) {
        return [ICACardDetailsViewController controllerWithCard:card];
    }
    else if ([card.bankIdentifier isEqualToString:@"Coop-kortet"]) {
        return [CoopCardDetailsViewController controllerWithCard:card];
    }
    else if ([card.bankIdentifier isEqualToString:@"Västtrafikkortet"]) {
        return [VasttrafikDetailsViewController controllerWithCard:card];
    }
    else if ([card.bankIdentifier isEqualToString:@"Skånetrafiken"]) {
        return [SkanetrafikenDetailsViewController controllerWithCard:card];
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.configuredCard.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

@implementation CardDetailsTableHeaderView
@synthesize title = _title;

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

+ (CardDetailsTableHeaderView *)view
{
    return [[[self alloc] init] autorelease];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0, RGB(100, 100, 100).CGColor);
    CGContextSetFillColorWithColor(context, RGB(255, 255, 255).CGColor);
    [self.title drawAtPoint:CGPointMake(10, 2) withFont:[UIFont boldSystemFontOfSize:18.0f]];
}

@end