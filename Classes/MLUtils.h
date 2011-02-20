//
//  Created by Björn Sållarp on 2009-07-17.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>


@interface MLUtils : NSObject {

}

+(float)calculateHeightOfTextFromWidth:(NSString*)text 
							  withFont:(UIFont*)font 
							labelWidth:(float)width 
						 lineBreakMode:(UILineBreakMode)lineBreakMode;

@end
