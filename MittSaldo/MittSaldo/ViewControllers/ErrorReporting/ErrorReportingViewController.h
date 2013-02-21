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

@interface ErrorReportingViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextView *infoTextView;
@property (nonatomic, retain) IBOutlet UITextView *statusTextView;
@property (nonatomic, retain) IBOutlet UILabel *problemLabel;
@property (nonatomic, retain) IBOutlet UIButton *errorReportingButton;

+ (ErrorReportingViewController *)controller;

- (IBAction)openErrorReportingAction:(id)sender;

@end
