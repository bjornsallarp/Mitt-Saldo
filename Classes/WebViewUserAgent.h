//
//  Created by Björn Sållarp on 2010-07-17.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>

@interface WebViewUserAgent : NSObject <UIWebViewDelegate> {
	NSString *userAgent;
	UIWebView *webView;
}
@property (nonatomic, retain) NSString *userAgent;
-(NSString*)userAgentString;
@end
