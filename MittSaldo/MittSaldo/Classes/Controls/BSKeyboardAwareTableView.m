//
//  Created by Björn Sållarp on 2010-08-14.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//
#import "BSKeyboardAwareTableView.h"


@implementation BSKeyboardAwareTableView

- (void)dealloc
{
    [_textField release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	if(self.textField && self.keyboardDelegate && [touch tapCount] == 1)
	{
		[self.keyboardDelegate textFieldShouldReturn:self.textField];
	}
	
	[super touchesBegan:touches withEvent:event];
}

- (void)textFieldStatusChanged:(UITextField*)txtField scrollToIndex:(NSIndexPath *)index
{
	CGRect myFrame = self.frame;
	float frameMovement = 165;
	BOOL movingUp = NO;
	
	if ([txtField isFirstResponder]) {
		myFrame.size.height -= frameMovement;
		self.textField = txtField;
		movingUp = YES;
	}
	else {
		myFrame.size.height += frameMovement;
		self.textField = nil;
	}
	
	[UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.3f];
    self.frame = myFrame;
    [UIView commitAnimations];
	
	if (movingUp) {
		// Only scroll on focused textboxes
		[self scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

@end
