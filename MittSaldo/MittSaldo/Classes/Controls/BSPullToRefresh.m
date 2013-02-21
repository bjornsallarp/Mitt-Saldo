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

#import <QuartzCore/QuartzCore.h>
#import "BSPullToRefresh.h"

static CGFloat const BSPullToRefreshViewHeight = 60;

@interface BSPullToRefresh ()
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, readwrite) BSPullToRefreshState state;
@property (nonatomic, assign) UIEdgeInsets originalScrollViewContentInset;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation BSPullToRefresh

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    if ((self = [super initWithFrame:CGRectMake(0, -1001, scrollView.bounds.size.width, 1000)])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.scrollView = scrollView;
        self.clipsToBounds = YES;
        
        self.originalScrollViewContentInset = scrollView.contentInset;
        
        self.contentView = [[[UIView alloc] initWithFrame:CGRectMake(72, self.bounds.size.height-BSPullToRefreshViewHeight, self.bounds.size.width - 72, BSPullToRefreshViewHeight)] autorelease];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.contentView];
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.contentView.bounds.size.width, 20)] autorelease];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.titleLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
        [self.contentView addSubview:self.titleLabel];
        
        self.arrow = [[[BSPullToRefreshArrow alloc] initWithFrame:CGRectMake(30, self.bounds.size.height - 54, 22, 48)] autorelease];
        [self addSubview:self.arrow];
        
        self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.activityIndicatorView.hidesWhenStopped = YES;
        self.activityIndicatorView.center = self.arrow.center;
        [self addSubview:self.activityIndicatorView];
        
        [scrollView addSubview:self];
    }

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview 
{
    if (newSuperview == self.scrollView) {
        [self startObservingScrollView];
    }
    else if (newSuperview == nil) {
        [self stopObservingScrollView];
    }
}

- (void)startObservingScrollView 
{    
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingScrollView 
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset 
{    
    if (self.pullToRefreshActionHandler) {
        if (self.state == BSPullToRefreshStateLoading) {
            CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, self.originalScrollViewContentInset.top + BSPullToRefreshViewHeight);
            self.scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        } else {
            CGFloat scrollOffsetThreshold = -self.contentView.frame.size.height - self.originalScrollViewContentInset.top;
            
            if (!self.scrollView.isDragging && self.state == BSPullToRefreshStateTriggered) {
                self.state = BSPullToRefreshStateLoading;
            }
            else if(contentOffset.y > scrollOffsetThreshold && contentOffset.y < -self.originalScrollViewContentInset.top && self.scrollView.isDragging && self.state != BSPullToRefreshStateLoading) {
                self.state = BSPullToRefreshStateVisible;
            }
            else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == BSPullToRefreshStateVisible) {
                self.state = BSPullToRefreshStateTriggered;
            }
            else if(contentOffset.y >= -self.originalScrollViewContentInset.top && self.state != BSPullToRefreshStateHidden) {
                self.state = BSPullToRefreshStateHidden;
            }
        }
    }
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.scrollView.contentInset = contentInset;
    } completion:^(BOOL finished) {
        if(self.state == BSPullToRefreshStateHidden && contentInset.top == self.originalScrollViewContentInset.top)
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.arrow.alpha = 0;
            } completion:nil];
    }];
}

- (void)setState:(BSPullToRefreshState)newState 
{
    if (_state == newState)
        return;
    
    _state = newState;
    
    switch (newState) {
        case BSPullToRefreshStateHidden:
        case BSPullToRefreshStateVisible:
            self.arrow.alpha = 1;
            self.titleLabel.text = NSLocalizedString(@"Pull to refresh...", nil);
            [self setScrollViewContentInset:self.originalScrollViewContentInset];
            [self rotateArrow:0 hide:NO];
            [self.activityIndicatorView stopAnimating];
            break;
            
        case BSPullToRefreshStateTriggered:
            self.titleLabel.text = NSLocalizedString(@"Release to refresh...", nil);
            [self rotateArrow:M_PI hide:NO];
            [self.activityIndicatorView stopAnimating];
            break;
            
        case BSPullToRefreshStateLoading:
            self.titleLabel.text = NSLocalizedString(@"Loading...",);
            UIEdgeInsets newInsets = self.originalScrollViewContentInset;
            newInsets.top = self.frame.origin.y*-1+self.originalScrollViewContentInset.top;
            newInsets.bottom = self.scrollView.contentInset.bottom;
            [self setScrollViewContentInset:newInsets];
            [self rotateArrow:0 hide:YES];
            [self.activityIndicatorView startAnimating];
            
            if (self.pullToRefreshActionHandler) {
                self.pullToRefreshActionHandler();
            }
            break;
    }
    
    if (self.pullToRefreshStateChanged) {
        self.pullToRefreshStateChanged(newState);
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide 
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrow.layer.opacity = !hide;
    } completion:NULL];
}

- (void)triggerUpdate 
{
    self.state = BSPullToRefreshStateLoading;
    [self.scrollView setContentOffset:CGPointMake(0, -BSPullToRefreshViewHeight) animated:YES];
}

- (void)startAnimating
{
    _state = BSPullToRefreshStateLoading;
    self.titleLabel.text = NSLocalizedString(@"Loading...",);
    UIEdgeInsets newInsets = self.originalScrollViewContentInset;
    newInsets.top = self.frame.origin.y*-1+self.originalScrollViewContentInset.top;
    newInsets.bottom = self.scrollView.contentInset.bottom;
    [self setScrollViewContentInset:newInsets];
    [self rotateArrow:0 hide:YES];
    [self.activityIndicatorView startAnimating];
    [self.scrollView setContentOffset:CGPointMake(0, -BSPullToRefreshViewHeight) animated:YES];
}

- (void)stopAnimating 
{
    self.state = BSPullToRefreshStateHidden;
}

@end

#pragma mark - UIScrollView (BSPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (BSPullToRefresh)

@dynamic pullToRefreshView;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler 
{
    self.pullToRefreshView.pullToRefreshActionHandler = actionHandler;
}

- (void)setPullToRefreshView:(BSPullToRefresh *)pullToRefreshView 
{
    [self willChangeValueForKey:@"pullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"pullToRefreshView"];
}

- (BSPullToRefresh *)pullToRefreshView 
{
    BSPullToRefresh *pullToRefreshView = objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
    if (!pullToRefreshView) {
        pullToRefreshView = [[[BSPullToRefresh alloc] initWithScrollView:self] autorelease];
        self.pullToRefreshView = pullToRefreshView;
    }
    return pullToRefreshView;
}

@end


#pragma mark - BSPullToRefreshArrow

@implementation BSPullToRefreshArrow
@synthesize arrowColor = _arrowColor;

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = [UIColor clearColor];
}

- (UIColor *)arrowColor 
{
    return _arrowColor ? _arrowColor : [UIColor grayColor];
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	
    // the rects above the arrow, it makes up 70% of the view size
    CGFloat stemHeight = self.bounds.size.height * 0.7;
    CGFloat blockHeight = (stemHeight / 6) - 2;
    CGRect square = CGRectMake(5, 0, self.bounds.size.width-10, blockHeight);
    
    for (int i = 0; i < 6; i++) {
        CGContextAddRect(c, CGRectOffset(square, 0, i * (blockHeight + 2)));        
    }    
    
	// the arrow, makes up the other 30%
    CGFloat triangleOffset = self.bounds.size.height * 0.7;
	CGContextMoveToPoint(c, 0, triangleOffset);
	CGContextAddLineToPoint(c, self.bounds.size.width/2, self.bounds.size.height);
	CGContextAddLineToPoint(c, self.bounds.size.width, triangleOffset);
	CGContextAddLineToPoint(c, 0, triangleOffset);
	CGContextClosePath(c);
	
	CGContextSaveGState(c);
	CGContextClip(c);
	
	
	// Gradient Declaration
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSArray* alphaGradientColors = [NSArray arrayWithObjects:
									(id)[self.arrowColor colorWithAlphaComponent:0].CGColor,
									(id)[self.arrowColor colorWithAlphaComponent:1].CGColor,
									nil];
	CGFloat alphaGradientLocations[] = {0, 0.8};
	CGGradientRef alphaGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)alphaGradientColors, alphaGradientLocations);
	
	
	CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
	
	CGContextRestoreGState(c);
	
	CGGradientRelease(alphaGradient);
	CGColorSpaceRelease(colorSpace);
}

@end
