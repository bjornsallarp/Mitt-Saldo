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

#import "AccountsTableHeaderView.h"

@interface AccountsTableHeaderView ()
@property (nonatomic, retain) UIActivityIndicatorView *updateIndicator;
@end

@implementation AccountsTableHeaderView

- (void)dealloc
{
    [_updateButton release];
    [_updateIndicator release];
    [_title release];
    [_updatedDate release];
    [super dealloc];
}

+ (AccountsTableHeaderView *)view
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        self.updateIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.updateIndicator.autoresizingMask = UIViewAutoresizingNone;
        self.updateIndicator.hidesWhenStopped = YES;
        
        self.updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.updateButton.autoresizingMask = UIViewAutoresizingNone;
        [self.updateButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if (!self.updateIndicator.superview && self.bounds.size.height >= 40) {
        [self addSubview:self.updateIndicator];        
    }
    
    if (!self.updateButton.superview && self.bounds.size.height >= 40) {
        [self addSubview:self.updateButton];
    }
    
    self.updateButton.frame = CGRectMake(self.bounds.size.width - 36, 7, 26, 26);
    self.updateIndicator.frame = CGRectMake(self.bounds.size.width - 30, 10, 20, 20);
}

- (void)showUpdateAnimation
{
    [self.updateIndicator startAnimating];
    self.updateButton.hidden = YES;
}

- (void)hideUpdateAnimation
{
    [self.updateIndicator stopAnimating];
    self.updateButton.hidden = NO;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.updatedDate) {
        CGContextSetFillColorWithColor(context, RGB(50, 50, 50).CGColor);
        [self.updatedDate drawAtPoint:CGPointMake(10, 22) withFont:[UIFont boldSystemFontOfSize:10.0f]];        
    }
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0, RGB(100, 100, 100).CGColor);
    CGContextSetFillColorWithColor(context, RGB(255, 255, 255).CGColor);
    [self.title drawAtPoint:CGPointMake(10, 2) withFont:[UIFont boldSystemFontOfSize:18.0f]];
}

@end
