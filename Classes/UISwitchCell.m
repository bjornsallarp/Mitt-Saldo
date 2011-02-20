//
//  Created by Björn Sållarp on 2010-06-07.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "UISwitchCell.h"


@implementation UISwitchCell
@synthesize switchControl; 


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
	
		self.textLabel.frame = CGRectMake(20, 13, 170, 20);
		

		switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(205, 10, 20, 20)];
		self.accessoryView = switchControl;		
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}


- (void)dealloc {
	[switchControl release];
    [super dealloc];
}


@end
