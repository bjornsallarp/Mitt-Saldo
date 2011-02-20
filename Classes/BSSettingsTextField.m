//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSSettingsTextField.h"


@implementation BSSettingsTextField
@synthesize settingsKey;


-(void)saveSetting
{
	NSString* value = [self.text length] > 0 ? self.text : nil;
	
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:value forKey:settingsKey];
	[settings synchronize];
}

-(UITableViewCell*)parentCell
{
	UIView *superView = [self superview];
	
	while (superView != nil) {

		// return if we find a cell
		if([superView isKindOfClass:[UITableViewCell class]])
			return (UITableViewCell*)superView;
		
		superView = [superView superview];
	}
	
	return nil;
}

-(void)dealloc
{
	[settingsKey release];
	[super dealloc];
}

@end
