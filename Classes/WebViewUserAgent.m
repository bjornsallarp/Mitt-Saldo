//
//  Created by Björn Sållarp on 2010-07-17.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//


#import "WebViewUserAgent.h"


@implementation WebViewUserAgent
@synthesize userAgent;

-(NSString*)userAgentString
{
	webView = [[UIWebView alloc] init];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
	
	// Wait for the web view to load our bogus request and give us the secret user agent.
	while (self.userAgent == nil) 
	{
		// This executes another run loop. 
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	return self.userAgent;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	// Store the user-agent. This stops the loop above
	self.userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
	
	// Return no, we don't care about executing an actual request.
	return NO;
}

- (void)dealloc 
{
	[webView release];
	[userAgent release];
    [super dealloc];
}


@end
