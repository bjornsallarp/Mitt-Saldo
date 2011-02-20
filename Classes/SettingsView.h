//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "KeyLockViewController.h"
#import "BSKeyLock.h"
#import "UISwitchCell.h"
#import "UITextInputCell.h"
#import "BSSettingsTextField.h"
#import "BSKeyboardAwareTableView.h"
#import "MittSaldoSettings.h"
#import "SliderCell.h"

@class MittSaldoAppDelegate;

@interface SettingsView : UIViewController <BSKeyLockDelegate, UITableViewDelegate, UITextFieldDelegate> {
	UISwitch *appLockSwitch;
	BSKeyboardAwareTableView *settingsTable;
	
	NSManagedObjectContext *managedObjectContext;
}
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet BSKeyboardAwareTableView *settingsTable;

-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender;
-(IBAction)clearStoredData:(id)sender;
-(IBAction)appLockSwitchChanged:(id)sender; 



@end
