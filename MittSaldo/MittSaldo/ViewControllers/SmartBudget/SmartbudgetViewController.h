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

@interface SmartbudgetViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIView *logoBgView;
@property (nonatomic, retain) IBOutlet UITextView *contentTextView;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, retain) IBOutlet UIButton *registerButton;

+ (id)controller;

@end
