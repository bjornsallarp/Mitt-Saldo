//
//  Created by Björn Sållarp on 2010-05-23.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>

@class MSConfiguredBank;

@interface WebBankViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

+ (id)controllerForBank:(MSConfiguredBank *)bank;

@property (nonatomic, retain) IBOutlet UIWebView *webBrowser;
@property (nonatomic, retain) IBOutlet UILabel *browserUrlLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *browserActivityIndicator;


@end
