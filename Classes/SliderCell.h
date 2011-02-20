//
//  SliderCell.h
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SliderCell : UITableViewCell {
	UISlider *slider;
	UILabel *sliderValueLabel;
	UILabel *sliderDescription;
	NSString *settingsKey;
}

@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) NSString *settingsKey;

@end
