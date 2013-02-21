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

#import "BSGradientView.h"

@implementation BSGradientView

static CGGradientRef GetCellBackgroundGradient()
{
    static CGGradientRef gradient = NULL;
    if ( !gradient ) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        NSArray *colors = [NSArray arrayWithObjects:(id)RGB(200, 200, 200).CGColor, (id)RGB(150, 150, 150).CGColor, nil];
        gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    
    return gradient;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(context, rect);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextDrawLinearGradient(context, GetCellBackgroundGradient(), startPoint, endPoint, 0);
    
    CGContextSetFillColorWithColor(context, RGB(120, 120, 120).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 1));
    
    CGContextSetFillColorWithColor(context, RGB(100, 100, 100).CGColor);    
    CGContextFillRect(context, CGRectMake(0, rect.size.height-1, rect.size.width, 1));
}

@end
