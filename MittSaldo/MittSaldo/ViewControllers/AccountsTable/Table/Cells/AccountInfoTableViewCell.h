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

#import <UIKit/UIKit.h>


@interface AccountInfoTableViewCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier showAvailableAmount:(BOOL)showAvailableAmount;

@property (nonatomic, retain) UILabel *accountTitle;
@property (nonatomic, retain) UILabel *accountAmount;
@property (nonatomic, retain) UILabel *accountAvailableAmount;

@end
