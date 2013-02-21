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

#import <UIKit/UIKit.h>
#import "BSMenuTableDelegate.h"

typedef enum {
    BSPanDirectionLeft = 0,
    BSPanDirectionRight,
} BSPanDirection;

@interface BSNavigationController : UIViewController
{
    CGRect _panOrigin;
    CGPoint _panVelocity;
    BSPanDirection _panDirection;
}

- (id)init;
- (id)initWithMenuTableController:(id<UITableViewDelegate, UITableViewDataSource>)menuTableController;
- (void)pushRootViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (IBAction)toggleMenu:(id)sender;

@property (nonatomic, retain) UITableView *menuTableView;
@property (nonatomic, retain) id<BSMenuTableDelegate> menuTableController;
@property (nonatomic, readonly) BOOL isMenuOpen;

@end