//
//  Created by Björn Sållarp on 2010-05-24.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSKeyLock.h"
#define POINT_SIZE			30.0
#define CIRCLE_SIZE			40.0
#define CIRCLE_X_START		35.0
#define CIRCLE_Y_START		55.0
#define CIRCLE_X_PADDING	110.0
#define CIRCLE_Y_PADDING	80.0

@implementation BSKeyLock

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		
		// Create rectangles to draw buttons in
		for (int i = 0; i < 9; i++) {
			// Calculate the row number
			int row = floor(i/3);
			
			// Calculate row position
			int rowPos = i % 3;
			
			// Create the rect calculating it's position on screen.
			keys[i] = CGRectMake(CIRCLE_X_START + (rowPos * CIRCLE_X_PADDING), 
								 CIRCLE_Y_START + (row * CIRCLE_Y_PADDING), 
								 CIRCLE_SIZE, 
								 CIRCLE_SIZE);
			
		}
		
		self.backgroundColor = [UIColor blackColor];
    }

    return self;
}

- (BOOL)isMultipleTouchEnabled
{
    return NO;
}

// Checks if the given point is inside a button. If so, the button position
// is returned. If not, -1 is returned.
- (int)isTouchingKey:(CGPoint)point
{
	// Go through our key rect array and see if the users' finger is
	// inside any of the rectangles
	for(int i = 0; i < 9; i++) {
		if (CGRectContainsPoint(keys[i], point)) {
			return i;
		}
	}
	
	return -1;
}

-(void)addKeyToCombo:(int)keyNumber
{
	keyCombination[keyComboCount] = keyNumber;
	keyComboCount++;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	keyComboCount = 0;
	keyComboIsValid = YES;
	
	CGPoint touchLocation = [[touches anyObject] locationInView:self];
	currentKeyTouch = [self isTouchingKey:touchLocation];
	
	if (currentKeyTouch > -1) {
		[self addKeyToCombo:currentKeyTouch];
	}
	
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// This occurs when the user lifts their finger from the screen
	currentKeyTouch = -1;
	[self setNeedsDisplay];
	
	// If a delegate is set we want to inform which keys has been touched
	if (keyComboCount > 0 && self.delegate != nil) {
		NSMutableArray *keyCombo = [[[NSMutableArray alloc] init] autorelease];
		
		for (int i = 0; i < keyComboCount; i++) {
			[keyCombo addObject:[NSNumber numberWithInt:keyCombination[i]]];
		}
		
		[self.delegate validateKeyCombination:keyCombo sender:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [[touches anyObject] locationInView:self];
	int key = [self isTouchingKey:touchLocation];
	
	if (key > -1 && key != currentKeyTouch) {
		BOOL addToCombo = YES;
		
		for (int i = 0; i < keyComboCount; i++) {
			if (keyCombination[i] == key) {
				addToCombo = NO;
				break;
			}
		}
		
		if (addToCombo) {
			[self addKeyToCombo:key];
            [self setNeedsDisplay];
		}
	}
	
	currentKeyTouch = key;	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Draw the lines between the points. Because we have three layers of controls
	// where all other elements are drawn above the lines we start with the lines. 
	if (keyComboCount > 1) {
		CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
		CGContextSetLineWidth(context, 15.0);
		
		// Add points to our stroke path
		for (int i = 0; i < keyComboCount; i++) {
			CGRect r = keys[keyCombination[i]];
			
			if (i == 0) {
				CGContextMoveToPoint(context, r.origin.x + (r.size.width/2), r.origin.y + (r.size.height/2));
			}
			else {
				CGContextAddLineToPoint(context, r.origin.x + (r.size.width/2), r.origin.y + (r.size.height/2));
			}
		}
		
		// Draw the line
		CGContextStrokePath(context);				
	}
	
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5);
	CGContextSetLineWidth(context, 15.0);
	
	
	// Draw semi transparent circles
	for (int i = 0; i < 9; i++) {
		CGContextAddEllipseInRect(context, keys[i]);		
	}
	CGContextStrokePath(context);
	
	// Draw white buttons on top of circles
	for (int i = 0; i < 9; i++) {
		CGRect r = keys[i];
		CGContextFillEllipseInRect(context, CGRectMake(r.origin.x + ((CIRCLE_SIZE - POINT_SIZE) / 2), 
													   r.origin.y + ((CIRCLE_SIZE - POINT_SIZE) / 2), 
													   POINT_SIZE, 
													   POINT_SIZE));
	}
	

	if (keyComboCount > 0) {
		// Draw key touch marker (the green thin marker)
		CGContextSetLineWidth(context, 2.0);
		
		if(keyComboIsValid) {
			CGContextSetRGBStrokeColor(context, 44.0/255.0, 207.0/255.0, 19.0/255.0, 1.0);
		}
		else {
			CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
		}
		
		for (int i = 0; i < keyComboCount; i++) {
			CGRect r = keys[keyCombination[i]];
			CGContextAddArc(context, r.origin.x + (r.size.width/2), r.origin.y + (r.size.height/2), 28.0, 0.0, M_PI*2, false);
			CGContextStrokePath(context);
		}
	}
	
	if (keyComboCount > 1) {
		// Draw line direction indicator (the red arrow). The loop starts at position
		// 1 because we can't draw an angle indicator with just one point. 
		for (int i = 1; i < keyComboCount; i++) {
			CGRect r = keys[keyCombination[i]];
			CGRect previousR = keys[keyCombination[i-1]];
			
			// Calculate angle between coordinates in radians
			float angle = atan2(r.origin.y-previousR.origin.y, r.origin.x-previousR.origin.x);
			
			// Save the context because we are rotating things here
			CGContextSaveGState(context);
			CGContextSetRGBFillColor(context, 0.8, 0, 0, 1);
			CGContextBeginPath(context);	
			
			// Translate the context so the center of the context is the center of the circle
			// where we want to draw the arrow
			CGContextTranslateCTM(context, CGRectGetMidX(previousR), CGRectGetMidY(previousR));
			
			// After translating we rotate
			CGContextRotateCTM(context, angle);
			
			// Set points that make up the triangle
			CGContextMoveToPoint(context, 18.0,-6.0);
			CGContextAddLineToPoint(context, 24.0,0.0);
			CGContextAddLineToPoint(context, 18.0,6.0);
			
			// Draw and fill the triangle
			CGContextClosePath(context);
			CGContextFillPath(context);
			
			// Restore our old context.
			CGContextRestoreGState(context);
		}
	}
}

- (void)deemKeyCombinationInvalid
{
	keyComboIsValid = NO;
	[self setNeedsDisplay];
}

@end
