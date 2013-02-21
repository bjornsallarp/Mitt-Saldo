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

@class BSKeyboardAwareTableView;
@class MSConfiguredBank;
@protocol BankSettingsViewDelegate;

@interface BankSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
@property (nonatomic, assign) id<BankSettingsViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet BSKeyboardAwareTableView *tableView;

- (id)initWithConfiguredBank:(MSConfiguredBank *)configuredBank;
- (id)initWithBankIdentifier:(NSString *)identifier;

+ (id)bankSettingsTableWithConfiguredBank:(MSConfiguredBank *)configuredBank;
+ (id)bankSettingsTableWithBankIdentifier:(NSString *)identifier;
@end


@protocol BankSettingsViewDelegate<NSObject>
@required
- (void)bankSettingsViewController:(BankSettingsViewController *)controller didAddBank:(MSConfiguredBank *)bank;
@end