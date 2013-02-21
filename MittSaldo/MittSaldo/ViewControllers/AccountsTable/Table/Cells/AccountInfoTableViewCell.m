//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//
#import "AccountInfoTableViewCell.h"

@implementation AccountInfoTableViewCell

- (void)dealloc 
{
	[_accountAmount release];
	[_accountTitle release];
	[_accountAvailableAmount release];
    [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier showAvailableAmount:(BOOL)showAvailableAmount
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        
		//
		// Create the label for the title row of text
		//
		self.accountTitle = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 2,
                                                                      self.bounds.size.width - self.indentationWidth,
                                                                      20.0)] autorelease];
		
		[self.contentView addSubview:self.accountTitle];
		self.accountTitle.backgroundColor = [UIColor clearColor];
		self.accountTitle.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		self.accountTitle.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		
		//
		// Create the label for the amount row of text
		//
		self.accountAmount = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 22,
                                                                        self.bounds.size.width - self.indentationWidth,
                                                                        20.0)] autorelease];
		
		[self.contentView addSubview:self.accountAmount];
		self.accountAmount.backgroundColor = [UIColor clearColor];
		self.accountAmount.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		self.accountAmount.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
		
		
		
		if (showAvailableAmount) {
			self.accountAvailableAmount = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 41,
                                                                                     self.bounds.size.width - self.indentationWidth,
                                                                                     20.0)] autorelease];
			
			[self.contentView addSubview:self.accountAvailableAmount];
			self.accountAvailableAmount.backgroundColor = [UIColor clearColor];
			self.accountAvailableAmount.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
			self.accountAvailableAmount.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
		}
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{  
    [super setSelected:selected animated:animated];
}

@end
