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
#import "CookieHelper.h"
#import "MittSaldoSettings.h"
#import "BankLogin.h"

@interface WebBankViewController : UIViewController <BankLoginDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
	IBOutlet UIWebView *webBrowser;
	IBOutlet UIView *browserStatusView;
	IBOutlet UILabel *browserUrlLabel;
	IBOutlet UIActivityIndicatorView *browserActivityIndicator;
	IBOutlet UISegmentedControl *bankSelectionMenu;
	
	id<BankLogin, NSObject> loginHelper;
    NSArray *configuredBanks;
}
@property (nonatomic, retain) NSArray *configuredBanks;

-(void)authenticateWithBank:(NSString*)bankIdentifier;
-(void)navigateToTransferPage:(NSString*)bankIdentifier;
-(NSString*)selectedBank;

@end
