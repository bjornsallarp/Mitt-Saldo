//
//  KundoViewController.h
//  KundoSDK
//
//  Created by Björn Sållarp (@bjornsallarp)
//

#import <UIKit/UIKit.h>

@interface KundoViewController : UIViewController <UIWebViewDelegate>

- (KundoViewController *)initWithUserEmail:(NSString *)userEmail userName:(NSString *)userName;
+ (void)presentFromViewController:(UIViewController *)viewController userEmail:(NSString *)userEmail userName:(NSString *)userName;

@end
