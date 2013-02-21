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

#import "BSNavigationController.h"
#import <QuartzCore/QuartzCore.h>

static int kNavbarCornerBackgroundTag = 1234;
static int kMenuTableWidth = 264;

@interface BSNavigationController()
@property (nonatomic, retain) CAShapeLayer *navbarRoundCornersLayer;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@end

@implementation BSNavigationController

- (void)dealloc
{
    [_navbarRoundCornersLayer release];
    [_menuTableController release];
    [_menuTableView release];
    [_navigationController release];
    [_panRecognizer release];
    [_tapRecognizer release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.navigationController = [[[UINavigationController alloc] init] autorelease];
    }
    
    return self;
}

- (id)initWithMenuTableController:(id<BSMenuTableDelegate>)menuTableController
{
    if ((self = [self init])) {
        self.menuTableController = menuTableController;
        
        if ([menuTableController respondsToSelector:@selector(setNavigationController:)]) {
            [menuTableController performSelector:@selector(setNavigationController:) withObject:self];
        }
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.menuTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)] autorelease];
    self.menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.menuTableView];
    self.menuTableView.scrollsToTop = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapGestureAction:)];
    tap.delegate = (id<UIGestureRecognizerDelegate>)self;
    self.tapRecognizer = tap;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.navigationBar addGestureRecognizer:pan];
    self.panRecognizer = pan;
    
    self.navigationController.view.frame = self.view.bounds;
    self.navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationController.view];
    
    if (self.menuTableController) {
        self.menuTableView.dataSource = self.menuTableController;
        self.menuTableView.delegate = self.menuTableController;
        [self.menuTableController reloadDataForTable:self.menuTableView];
    }
    
    self.navigationController.view.clipsToBounds = NO;
    self.navigationController.view.layer.shadowRadius = 10;
    self.navigationController.view.layer.shadowOpacity = 1;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationController.view.bounds].CGPath;
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 10)];
    blackView.tag = kNavbarCornerBackgroundTag;
    blackView.opaque = YES;
    blackView.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar.superview insertSubview:blackView belowSubview:self.navigationController.navigationBar];
    [blackView release];
    
    [self addChildViewController:self.navigationController];
    [self.navigationController didMoveToParentViewController:self];
    
    // Listen to changes to the viewcontrollers frame
    [self.navigationController.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // Make round corners on the navbar
    [self roundNavbarCorners];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self roundNavbarCorners];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    // Adjust the mask according to the new layout
    [self roundNavbarCorners];
}

#pragma mark - Private methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.navigationController.view) {
        
        UIView *navView = self.navigationController.view; 
        if (navView.frame.origin.x > 0) {
            self.navigationController.visibleViewController.view.userInteractionEnabled = NO;
            [self.navigationController.view addGestureRecognizer:self.tapRecognizer];
        
            [self.navigationController.navigationBar.superview viewWithTag:kNavbarCornerBackgroundTag].hidden = YES;
        }
        else if ([self.navigationController.navigationBar.superview viewWithTag:kNavbarCornerBackgroundTag].hidden) {
            [self.navigationController.view removeGestureRecognizer:self.tapRecognizer];
            self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
            
            [self.navigationController.navigationBar.superview viewWithTag:kNavbarCornerBackgroundTag].hidden = NO;
        }
    }
}

- (void)roundNavbarCorners
{   
    // Round the top edges on the navigation bar
    CGRect bounds = [self.navigationController navigationBar].layer.bounds;
    
    // We're only masking the top, after rotation with modal view visible the height
    // is not always updated here so going from landscape to portrait will mask the
    // bottom part of the navbar.
    bounds.size.height = 100; 
    
    if (!self.navbarRoundCornersLayer) {
        self.navbarRoundCornersLayer = [CAShapeLayer layer];
        [[self.navigationController navigationBar].layer addSublayer:self.navbarRoundCornersLayer];
        [self.navigationController navigationBar].layer.mask = self.navbarRoundCornersLayer;
    }

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds 
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(4.0, 4.0)];
    
    self.navbarRoundCornersLayer.frame = bounds;
    self.navbarRoundCornersLayer.path = maskPath.CGPath;
}

#pragma mark - Public methods

- (void)pushRootViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn-menu.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu:)] autorelease];
    
    // Reset, remove the entire viewcontroller heirarchy as we're pusing in a new one!
    self.navigationController.viewControllers = [NSArray array];
    [self.navigationController pushViewController:viewController animated:NO];
    
    if (self.navigationController.view.frame.origin.x > 0) {
        [self toggleMenu:nil];
    }
}

#pragma mark - Actions

- (IBAction)toggleMenu:(id)sender
{    
    CGRect newRect = self.navigationController.view.frame;
    if (newRect.origin.x == 0) {
        
        // Reload the data before showing it
        [self.menuTableController reloadDataForTable:self.menuTableView];
        newRect.origin.x = kMenuTableWidth;
    }
    else {
        newRect.origin.x = 0;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
       self.navigationController.view.frame = newRect; 
    }];
}

#pragma mark - Accessors

- (BOOL)isMenuOpen
{
    return self.navigationController.view.frame.origin.x > 0;
}

#pragma mark - Gesture recognizers

- (void)menuTapGestureAction:(UITapGestureRecognizer *)gesture 
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self toggleMenu:nil];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture 
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // reload table data
        [self.menuTableController reloadDataForTable:self.menuTableView];
        
        _panOrigin = self.navigationController.view.frame;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view].x > 0) {
            _panDirection = BSPanDirectionRight;
        } else {
            _panDirection = BSPanDirectionLeft;
        }
        
        [self.navigationController.view removeGestureRecognizer:self.tapRecognizer];
        self.navigationController.visibleViewController.view.userInteractionEnabled = YES;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {      
        CGPoint velocity = [gesture velocityInView:self.view];
        if((velocity.x * _panVelocity.x + velocity.y * _panVelocity.y) < 0) {
            _panDirection = (_panDirection == BSPanDirectionRight) ? BSPanDirectionLeft : BSPanDirectionRight;
        }
        
        _panVelocity = velocity;        
        
        CGPoint translation = [gesture translationInView:self.navigationController.view];
        CGRect frame = CGRectOffset(_panOrigin, translation.x, 0);
        
        if (frame.origin.x < 0) {
            [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];
            frame.origin.x = MAX(0, frame.origin.x);
            _panOrigin = frame;
        }
        
        self.navigationController.view.frame = frame;
    } 
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGRect newRect = self.navigationController.view.frame;
        
        if (_panDirection == BSPanDirectionRight) {
            newRect.origin.x = kMenuTableWidth;
        } 
        else {
            newRect.origin.x = 0;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.view.frame = newRect;
        } completion:^(BOOL finished) {
            
        }];  
    }
}


@end
