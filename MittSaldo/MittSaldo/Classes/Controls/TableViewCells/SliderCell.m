//
//  Created by Björn Sållarp on 2010-10-23.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SliderCell.h"

@interface SliderCell ()
@property (nonatomic, retain) UILabel *sliderValueLabel;
@property (nonatomic, retain) UILabel *sliderDescription;
@end

@implementation SliderCell

- (void)dealloc 
{
    [_sliderDescription release];
    [_sliderValueLabel release];
	[_slider release];
	[_settingsKey release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        int controlXOffset = 10;
        int controlWidth = self.bounds.size.width - self.indentationWidth * 2;
        
		self.slider = [[[UISlider alloc] initWithFrame:CGRectMake(controlXOffset, 35, controlWidth, 30)] autorelease];
        self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		[self.slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
		
		self.sliderValueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 25)] autorelease];
		self.sliderValueLabel.textAlignment = UITextAlignmentRight;
		self.sliderValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		self.sliderValueLabel.backgroundColor = [UIColor clearColor];
		
		self.sliderDescription = [[[UILabel alloc] initWithFrame:CGRectMake(controlXOffset, 55, controlWidth, 50)] autorelease];
		self.sliderDescription.text = @"Sätt den tid applikationen kan vara stängd och öppnas igen utan att kräva inloggning";
		self.sliderDescription.lineBreakMode = UILineBreakModeWordWrap;
		self.sliderDescription.numberOfLines = 10;
		self.sliderDescription.font = [UIFont systemFontOfSize:11];
		self.sliderDescription.backgroundColor = [UIColor clearColor];
        self.sliderDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		
		[self.contentView addSubview:self.sliderDescription];
		[self.contentView addSubview:self.slider];
		[self.contentView addSubview:self.sliderValueLabel];
	}
	
	return self;
}

- (void)sliderAction:(UISlider *)sender
{	
	self.sliderValueLabel.text = [NSString stringWithFormat:@"%ds", (int)[sender value]];
	
	if (self.settingsKey != nil) {
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
		[settings setValue:[NSNumber numberWithFloat:self.slider.value] forKey:self.settingsKey];
		[settings synchronize];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    self.sliderValueLabel.font = self.textLabel.font;
    
    CGRect frame = self.textLabel.frame;
    frame.size.height = 44;
    self.textLabel.frame = frame;
    
    [self.contentView insertSubview:self.textLabel belowSubview:self.sliderDescription];
    
	// Update the slider
	[self sliderAction:self.slider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
}

@end
