//
//  AccountInfoTableView.m
//  MittSaldo
//
//  Created by Björn Sållarp on 12/5/10.
//  Copyright 2010 Björn Sållarp. All rights reserved.
//

#import "AccountInfoTableView.h"


@implementation AccountInfoTableView
@synthesize accountTitle, accountAmount, accountAvailableAmount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier showAvailableAmount:(BOOL)showAvailableAmount
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
		//
		// Create the label for the title row of text
		//
		accountTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 2,
																 self.bounds.size.width - self.indentationWidth,
																 20.0)];
		
		[self.contentView addSubview:accountTitle];
		accountTitle.backgroundColor = [UIColor clearColor];
		accountTitle.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		accountTitle.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		
		//
		// Create the label for the amount row of text
		//
		accountAmount = [[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 22,
																  self.bounds.size.width - self.indentationWidth,
																  20.0)];
		
		[self.contentView addSubview:accountAmount];
		accountAmount.backgroundColor = [UIColor clearColor];
		accountAmount.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		accountAmount.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
		
		
		
		if(showAvailableAmount)
		{
			accountAvailableAmount = [[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 41,
																			   self.bounds.size.width - self.indentationWidth,
																			   20.0)];
			
			[self.contentView addSubview:accountAvailableAmount];
			accountAvailableAmount.backgroundColor = [UIColor clearColor];
			accountAvailableAmount.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
			accountAvailableAmount.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
		}
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[accountAmount release];
	[accountTitle release];
	[accountAvailableAmount release];
    [super dealloc];
}


@end
