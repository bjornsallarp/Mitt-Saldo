//
//  Created by Björn Sållarp on 2010-05-24.
//  NO Copyright 2009 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>


@protocol BSKeyLockDelegate<NSObject>
@required
-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender;
@end

@interface BSKeyLock : UIView {
	CGRect keys[9];
	int currentKeyTouch;
	int keyCombination[9];
	int keyComboCount;
	BOOL keyComboIsValid;
	
	id<BSKeyLockDelegate, NSObject> delegate;
	
}
@property (assign) id<BSKeyLockDelegate, NSObject> delegate;

-(void)deemKeyCombinationInvalid;



@end


