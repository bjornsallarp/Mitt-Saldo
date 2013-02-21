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

@interface BSPullToRefreshArrow : UIView
@property (nonatomic, strong) UIColor *arrowColor;
@end


typedef enum BSPTRS {
    BSPullToRefreshStateHidden = 0,
	BSPullToRefreshStateVisible = 1,
    BSPullToRefreshStateTriggered = 2,
    BSPullToRefreshStateLoading = 3
} BSPullToRefreshState;


@interface BSPullToRefresh : UIView
- (id)initWithScrollView:(UIScrollView *)scrollView;
- (void)triggerUpdate;
- (void)startAnimating;
- (void)stopAnimating;
@property (nonatomic, strong) BSPullToRefreshArrow *arrow;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);
@property (nonatomic, copy) void (^pullToRefreshStateChanged)(BSPullToRefreshState state);
@end


@interface UIScrollView (BSPullToRefresh)
- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;
@property (nonatomic, strong) BSPullToRefresh *pullToRefreshView;
@end
