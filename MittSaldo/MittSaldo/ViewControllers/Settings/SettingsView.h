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

#import "BSKeyLock.h"
#import "BSKeyboardAwareTableView.h"

@interface SettingsView : UIViewController <BSKeyLockDelegate, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet BSKeyboardAwareTableView *settingsTable;

+ (id)controller;

- (void)validateKeyCombination:(NSArray *)keyCombination sender:(id)sender;
- (IBAction)clearStoredData:(id)sender;
- (IBAction)appLockSwitchChanged:(id)sender;

@end
