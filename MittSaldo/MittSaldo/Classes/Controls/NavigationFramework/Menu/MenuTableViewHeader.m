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

#import "MenuTableViewHeader.h"

@implementation MenuTableViewHeader

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

static CGGradientRef GetCellBackgroundGradient()
{
    static CGGradientRef gradient = NULL;
    if ( !gradient ) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        NSArray *colors = [NSArray arrayWithObjects:(id)RGB(67, 74, 94).CGColor, (id)RGB(57, 64, 82).CGColor, nil];
        gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    
    return gradient;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextAddRect(context, rect);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, GetCellBackgroundGradient(), startPoint, endPoint, 0);
    
    CGContextSetFillColorWithColor(context, RGB(78, 85, 103).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 1));
    
    CGContextSetFillColorWithColor(context, RGB(36, 42, 55).CGColor);    
    CGContextFillRect(context, CGRectMake(0, rect.size.height-1, rect.size.width, 1));
    
    CGContextSetShadowWithColor(context, CGSizeMake(-1, 1), 0, RGB(41, 46, 58).CGColor);
    CGContextSetFillColorWithColor(context, RGB(125, 129, 146).CGColor);
    [self.title drawAtPoint:CGPointMake(10, 2) withFont:[UIFont boldSystemFontOfSize:12.0f]];
}

@end
