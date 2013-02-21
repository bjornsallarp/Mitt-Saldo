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

#import "AccountTotalsTableViewCell.h"

@interface AccountTotalsTableViewCell()
@property (nonatomic, retain) UILabel *accountsAmountLabel;
@property (nonatomic, retain) UILabel *accountsAvailableAmountLabel;
@property (nonatomic, retain) UILabel *accountsAmountTitleLabel;
@property (nonatomic, retain) UILabel *accountsAvailableAmountTitleLabel;
@end

@implementation AccountTotalsTableViewCell

- (void)dealloc 
{
    [_accountsAmountLabel release];
    [_accountsAvailableAmountLabel release];
	[_accountsAmountTitleLabel release];
	[_accountsAvailableAmountTitleLabel release];
    [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        
        int titleLabelWidth = 100;
        
		//
		// Create the label for the amount row of text
		//
        self.accountsAmountTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 5, titleLabelWidth, 20.0)] autorelease];
        self.accountsAmountTitleLabel.text = NSLocalizedString(@"AccountBalance", nil);
		[self.contentView addSubview:self.accountsAmountTitleLabel];
        
		self.accountsAmountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth + titleLabelWidth, 5,
                                                                        self.bounds.size.width - self.indentationWidth - titleLabelWidth - 10,
                                                                        20.0)] autorelease];
		
		[self.contentView addSubview:self.accountsAmountLabel];

        
		
        self.accountsAvailableAmountTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth, 30, titleLabelWidth, 20.0)] autorelease];
        self.accountsAvailableAmountTitleLabel.text = NSLocalizedString(@"AvailableAccountBalance", nil);
		[self.contentView addSubview:self.accountsAvailableAmountTitleLabel];
        
        self.accountsAvailableAmountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.indentationWidth + titleLabelWidth, 30,
                                                                                     self.bounds.size.width - self.indentationWidth - titleLabelWidth - 10,
                                                                                     20.0)] autorelease];
			
		[self.contentView addSubview:self.accountsAvailableAmountLabel];
        
        self.accountsAmountLabel.textAlignment = self.accountsAvailableAmountLabel.textAlignment = UITextAlignmentRight;
        self.accountsAmountLabel.autoresizingMask = self.accountsAvailableAmountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        self.accountsAmountLabel.opaque = self.accountsAvailableAmountLabel.opaque = YES;
        
        UIColor *highlightColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		self.accountsAmountLabel.highlightedTextColor = highlightColor;
        self.accountsAvailableAmountLabel.highlightedTextColor = highlightColor;
        self.accountsAvailableAmountTitleLabel.highlightedTextColor = highlightColor;
        self.accountsAmountTitleLabel.highlightedTextColor = highlightColor;
        
        UIFont *font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        self.accountsAvailableAmountTitleLabel.font = font;
        self.accountsAmountTitleLabel.font = font;
		self.accountsAmountLabel.font = font;
        self.accountsAvailableAmountLabel.font = font;
    }
    
    return self;
}

- (void)setAccountsAmount:(NSString *)accountsAmount
{
    self.accountsAmountLabel.text = accountsAmount;
}

- (NSString *)accountsAmount
{
    return self.accountsAmountLabel.text;
}

- (void)setAccountsAvailableAmount:(NSString *)accountsAvailableAmount
{
    self.accountsAvailableAmountLabel.text = accountsAvailableAmount;
}

- (NSString *)accountsAvailableAmount
{
    return self.accountsAvailableAmountLabel.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
