//
//  Created by Björn Sållarp on 2010-06-07.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "UITextInputCell.h"

@implementation UITextInputCell

- (void)dealloc 
{
	[_textField release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		// This is the frame for the textbox
		CGRect textBoxRect = CGRectMake(120, 
										(self.frame.size.height - 30) / 2,
										self.frame.size.width - 130, 
										30);
		
		self.textField = [[[BSSettingsTextField alloc] initWithFrame:textBoxRect] autorelease];
		
		// Allow the textbox to grow to the right. This is needed for things to look good on the iPad
		self.textField.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
		self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		
		// We're adding the control to the labels superview because that view is correctly moved/indented on the iPad
		[self.textLabel.superview addSubview:self.textField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
}

@end
