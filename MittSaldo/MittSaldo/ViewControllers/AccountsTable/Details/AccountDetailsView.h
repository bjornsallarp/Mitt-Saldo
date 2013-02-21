//
//  Created by Björn Sållarp on 2010-05-16.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>

@class MSBankAccount;

@interface AccountDetailsView : UIViewController <UITableViewDelegate, UITextFieldDelegate>

+ (id)accountDetailsViewForAccount:(MSBankAccount *)account;

@property (nonatomic, retain) IBOutlet UITableView *detailsTable;
@property (nonatomic, retain) MSBankAccount *accountToEdit;

@end
