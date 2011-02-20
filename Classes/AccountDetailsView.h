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
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "BankAccount.h"


@interface AccountDetailsView : UIViewController <UITableViewDelegate, UITextFieldDelegate> {
	IBOutlet UITableView *detailsTable;
	BankAccount *accountToEdit;
	NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) BankAccount *accountToEdit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil account:(BankAccount*)account;
@end
