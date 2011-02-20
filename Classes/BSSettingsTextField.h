//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>


@interface BSSettingsTextField : UITextField {
	NSString *settingsKey;
}
@property (nonatomic, retain) NSString *settingsKey;

-(void)saveSetting;
-(UITableViewCell*)parentCell;


@end
