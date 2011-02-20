//
//  AccountInfoTableView.h
//  MittSaldo
//
//  Created by Björn Sållarp on 12/5/10.
//  Copyright 2010 Björn Sållarp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountInfoTableView : UITableViewCell {
	UILabel *accountTitle;
	UILabel *accountAmount;
	UILabel *accountAvailableAmount;
}

- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier 
showAvailableAmount:(BOOL)showAvailableAmount;

@property (nonatomic, retain) UILabel *accountTitle;
@property (nonatomic, retain) UILabel *accountAmount;
@property (nonatomic, retain) UILabel *accountAvailableAmount;

@end
