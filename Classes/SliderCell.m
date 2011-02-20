//
//  SliderCell.m
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SliderCell.h"
#import "MLUtils.h"

@implementation SliderCell
@synthesize slider, settingsKey;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		slider = [[UISlider alloc] initWithFrame:self.textLabel.frame];
		
		
		[slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
		
		sliderValueLabel = [[UILabel alloc] initWithFrame:self.textLabel.frame];
		sliderValueLabel.textAlignment = UITextAlignmentRight;
		sliderValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		sliderValueLabel.backgroundColor = [UIColor clearColor];
		
		sliderDescription = [[UILabel alloc] initWithFrame:CGRectZero];
		sliderDescription.text = @"Sätt den tid applikationen kan vara stängd och öppnas igen utan att kräva inloggning";
		sliderDescription.lineBreakMode = UILineBreakModeWordWrap;
		sliderDescription.numberOfLines = 10;
		sliderDescription.font = [UIFont systemFontOfSize:11];
		sliderDescription.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:sliderDescription];
		[self.contentView addSubview:slider];
		[self.contentView addSubview:sliderValueLabel];
		
		[sliderValueLabel release];
		[sliderDescription release];
	}
	
	return self;
}

-(void)sliderAction:(UISlider*)sender
{	
	sliderValueLabel.text = [NSString stringWithFormat:@"%ds", (int)[sender value]];
	
	if(settingsKey != nil)
	{
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		[settings setValue:[NSNumber numberWithFloat:slider.value] forKey:settingsKey];
		[settings synchronize];
	}
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect textLabelRect = self.textLabel.frame;
	CGRect sliderRect = self.textLabel.frame;
	CGRect sliderValueRect = self.textLabel.frame;
	CGRect sliderDescriptionRect = self.textLabel.frame;
	
	textLabelRect.size.height = 40;
	textLabelRect.size.width -= 50;
	self.textLabel.frame = textLabelRect;
	
	sliderRect.size.height = 30;
	sliderRect.origin.y = 35;
	slider.frame = sliderRect;

	sliderValueRect.origin.x = sliderValueRect.size.width - 50;
	sliderValueRect.size.height = 40;
	sliderValueRect.size.width = 50;
	sliderValueLabel.frame = sliderValueRect;
	sliderValueLabel.font = self.textLabel.font;

	sliderDescriptionRect.origin.y = 75;
	sliderDescriptionRect.size.height = [MLUtils calculateHeightOfTextFromWidth:sliderDescription.text
																	   withFont:sliderDescription.font 
																	 labelWidth:sliderDescriptionRect.size.width 
																  lineBreakMode:sliderDescription.lineBreakMode];
	
	sliderDescription.frame = sliderDescriptionRect;
	// Update the slider
	[self sliderAction:slider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}


- (void)dealloc {
	[slider release];
	[settingsKey release];
    [super dealloc];
}


@end
