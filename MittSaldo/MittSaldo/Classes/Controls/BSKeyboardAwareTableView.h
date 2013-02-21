//
//  Created by Björn Sållarp on 2010-08-10.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>

@interface BSKeyboardAwareTableView : UITableView
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, assign) id<UITextFieldDelegate, NSObject> keyboardDelegate;
- (void)textFieldStatusChanged:(UITextField*)txtField scrollToIndex:(NSIndexPath *)index;
@end
