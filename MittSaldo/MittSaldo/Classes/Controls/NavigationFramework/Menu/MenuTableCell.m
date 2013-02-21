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

#import "MenuTableCell.h"

@implementation MenuTableCell

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isHighlighted) {
        CGContextSetFillColorWithColor(context, RGB(36, 42, 55).CGColor);
        CGContextFillRect(context, rect);
    }
    
    CGContextSetFillColorWithColor(context, RGB(62, 69, 85).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0,rect.size.width, 1));
    
    CGContextSetFillColorWithColor(context, RGB(36, 42, 55).CGColor);    
    CGContextFillRect(context, CGRectMake(0, rect.size.height-1, rect.size.width, 1));
    
    CGContextSetShadow(context, CGSizeMake(-1, 1), 0);
    CGContextSetFillColorWithColor(context, RGB(196, 204, 218).CGColor);
    
    int xOffset = 10;
    if (self.imageView.image != nil) {
        xOffset += self.imageView.frame.origin.x + self.imageView.bounds.size.width; 
    }

    [self.title drawAtPoint:CGPointMake(xOffset, 12) withFont:[UIFont systemFontOfSize:18.0f]];        
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    isHighlighted = highlighted;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{

}

@end
