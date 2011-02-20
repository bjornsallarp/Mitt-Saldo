//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <UIKit/UIKit.h>
#import "SettingsView.h"
#import <CoreData/CoreData.h>
#import "RootViewController.h"
#import "SettingsView.h"
#import "WebBankViewController.h"
#import "BSKeyLock.h"
#import "CoreDataHelper.h"
#import "WebViewUserAgent.h"
#import "MittSaldoSettings.h"


@interface MittSaldoAppDelegate : NSObject <UIApplicationDelegate, BSKeyLockDelegate> {
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	UITabBarController *tabController;
	
    UIWindow *window;
    UINavigationController *navigationController;
	IBOutlet RootViewController *rootView;
	IBOutlet SettingsView *settingsView;
	IBOutlet WebBankViewController *webView;
	KeyLockViewController *keyLockView;
}

-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender;
-(void)openKeyLockView;


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UITabBarController *tabController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootView;
@property (nonatomic, retain) IBOutlet SettingsView *settingsView;
@property (nonatomic, retain) IBOutlet WebBankViewController *webView;





@end

