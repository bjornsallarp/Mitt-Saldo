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

#import <Foundation/Foundation.h>
#import "BSNavigationController.h"

@class AccountsTableViewController;

@interface MenuTableSection : NSObject
+ (MenuTableSection *)section;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *rows;
@end

@interface MenuTableRow : NSObject
- (id)initWithTitle:(NSString *)title iconImageName:(NSString *)iconImageName rowSelectedActionHandler:(void (^)(void))actionHandler;
+ (MenuTableRow *)rowWithTitle:(NSString *)title iconImageName:(NSString *)iconImageName rowSelectedActionHandler:(void (^)(void))actionHandler;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *iconImageName;
@property (nonatomic, copy) void (^rowSelectedActionHandler)(void);
@end

@interface MenuTableController: NSObject <BSMenuTableDelegate>

@property (nonatomic, retain) BSNavigationController *navigationController;
@property (nonatomic, retain) UIViewController *accountBalanceViewController;

@end
