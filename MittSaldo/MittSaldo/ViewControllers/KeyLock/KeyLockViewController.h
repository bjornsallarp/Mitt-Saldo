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

@interface KeyLockViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil headerText:(NSString*)text;

@property (assign) id appDelegate;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *keyLockImage;
@property (nonatomic, retain) NSString *headerText;
@end
