//
//  Created by Björn Sållarp on 2010-06-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>


@interface AboutMittSaldoViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	UIToolbar *topToolbar;
	UIBarButtonItem *backButton;
	UIBarButtonItem *aboutButton;
	UIBarButtonItem *stopButton;
	UIBarButtonItem *errorReportButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *stopButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *errorReportButton;


-(IBAction)stopButtonClick:(id)sender;
-(IBAction)backButtonClick:(id)sender;
-(IBAction)aboutButtonClick:(id)sender;
-(IBAction)errorReportButtonClick:(id)sender;


@end
