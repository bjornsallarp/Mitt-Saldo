//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <objc/runtime.h>
#import "MittSaldoAppDelegate.h"
#import "KeyLockViewController.h"
#import "MittSaldoSettings.h"
#import "MenuTableController.h"
#import "BSNavigationController.h"
#import "AccountsViewController.h"
#import "MSUpgradeV1ToV2.h"
#import "InAppPurchaseManager.h"
#import "MSLServicesFactory.h"
#import "MSLNetworkingClient.h"

#ifdef TACTIVO
#import "PBVerificationController.h"
#import "PBReferenceDatabase.h"
#endif

static int kTactivoUseKeypadInsteadAlertViewTag = 100;

@interface MittSaldoAppDelegate ()
@property (nonatomic, retain) UIViewController *keyLockView;
@property (nonatomic, retain) BSNavigationController *navController;
@property (nonatomic, retain) AccountsViewController *accountsController;
@end

@implementation MittSaldoAppDelegate

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{   
    // Boot up the purchase manager
    [[InAppPurchaseManager sharedManager] loadStore];
    
    [self runVersionUpgrades];
    
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // We override the user agent for the app so we're always sending the same user-agent
    NSString *userAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    
	if (IDIOM == IPAD) {
        userAgent = @"Mozilla/5.0(iPad; U; CPU OS 4_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8F191 Safari/6533.18.5";
	}

    [MSLNetworkingClient sharedClient].userAgent = userAgent;
    // Set a static user agent, no swizzling required!
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"UserAgent": userAgent }];
    
    [[UINavigationBar appearance] setTintColor:RGB(66, 84, 100)];
    [[UISlider appearance] setMinimumTrackTintColor:RGB(66, 84, 100)];
    [[UISwitch appearance] setOnTintColor:RGB(66, 84, 100)];
    
	application.applicationSupportsShakeToEdit = YES;

	NSManagedObjectContext *context = [self managedObjectContext];
	// We're not using undo. By setting it to nil we reduce the memory footprint of the app
	[context setUndoManager:nil];

    self.accountsController = [AccountsViewController controller];
    MenuTableController *menuTableController = [[[MenuTableController alloc] init] autorelease];
    menuTableController.accountBalanceViewController = self.accountsController;
    self.navController = [[[BSNavigationController alloc] initWithMenuTableController:menuTableController] autorelease];
    [self.navController pushRootViewController:menuTableController.accountBalanceViewController animated:NO];
    
    if ([MittSaldoSettings isTactivoLockActive]) {
        [self openTactivoLockView];
    }
    else if ([MittSaldoSettings isKeyLockActive]) {
        [self openKeyLockView];
    }
    else {
        self.window.rootViewController = self.navController;
    }

    [self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	// Clear any background settings, the app is terminating
	[MittSaldoSettings setApplicationDidEnterBackground:nil];
	
	NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// If the keylock is active we want to prompt to unlock when using fast app switching
	if ([MittSaldoSettings isKeyLockActive] && self.keyLockView == nil) {
        // Close any modal views that might be open
        [self.window.rootViewController dismissModalViewControllerAnimated:NO];
        
        // remove the main application from view otherwise the user 
		// will get a glimps of it when the application resume
        self.window.rootViewController = nil;
	}
	
	// Store the date and time for when the application enter background mode
	[MittSaldoSettings setApplicationDidEnterBackground:[NSDate date]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self runVersionUpgrades];
    
	NSDate *backgroundDate = [MittSaldoSettings getApplicationDidEnterBackground];
	
	// Time difference between when the application was closed and now
	NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:backgroundDate];
	
	// If keylock is activated we want to present it if the application was closed for more than configured time
	if (!self.keyLockView && diff > [MittSaldoSettings multitaskingTimeout]) {
        if ([MittSaldoSettings isTactivoLockActive]) {
            [self openTactivoLockView];
        }
        else if ([MittSaldoSettings isKeyLockActive]) {
            [self openKeyLockView];            
        }
    }
    
    if (diff > 60 && [MittSaldoSettings isUpdateOnStartEnabled]) {
        [self.accountsController updateServicesWhenVisible];
    }
	
	// If the key lock wasn't opened, we move the application view back onto the window
	if (self.keyLockView == nil && [MittSaldoSettings isKeyLockActive]) {
		self.window.rootViewController = self.navController;
        [self.navController.navigationController.visibleViewController viewDidAppear:NO];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self applicationWillEnterForeground:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self applicationDidEnterBackground:application];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kTactivoUseKeypadInsteadAlertViewTag) {
        if (buttonIndex == 1) {
            [self openKeyLockView];
        }
    }
}

#pragma mark - Tactivo lock methods

- (void)openTactivoLockView
{
    #ifdef TACTIVO   
    PBVerificationController *verificationController = [[[PBVerificationController alloc] initWithDatabase:[PBReferenceDatabase sharedClass] andFingers:[[PBReferenceDatabase sharedClass] getEnrolledFingers] andDelegate:(id<PBVerificationDelegate>)self andTitle:NSLocalizedString(@"SwipeFingerprintToUnlock", nil)] autorelease];
    verificationController.config.timeout = 0xFFFF;
    
    UINavigationController *tactivoNavController = [[[UINavigationController alloc] initWithRootViewController:verificationController] autorelease];
    self.window.rootViewController = tactivoNavController;
    self.keyLockView = tactivoNavController;
    #endif
}

#ifdef TACTIVO
- (void)tactivoNotConnected
{
    if ([MittSaldoSettings isKeyLockActive]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                        message:@"Tactivo verkar inte vara ansluten. Vill du logga in via applikationslåset istället?" 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"No", nil) 
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alert.tag = kTactivoUseKeypadInsteadAlertViewTag;
        [alert show];
        [alert release];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TactivoNotAccessibleTitle", nil)
                                                            message:NSLocalizedString(@"TactivoNotAccessibleMessage", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        [alertView release];
    }
}

- (void)cancelTactivoVerification
{
    if ([MittSaldoSettings isKeyLockActive]) {
        [self openKeyLockView];
    }
}

- (void)verificationVerifiedFinger:(PBBiometryFinger *)finger
{
    if (finger) {
        [self.keyLockView.view removeFromSuperview];
		self.window.rootViewController = self.navController;
		self.keyLockView = nil;
    }
}
#endif

#pragma mark - Key lock methods

- (void)openKeyLockView
{	
    self.window.rootViewController = nil;
    
    KeyLockViewController *keyLock = [[[KeyLockViewController alloc] initWithNibName:@"KeyLockViewController" bundle:nil headerText:nil] autorelease];
	keyLock.appDelegate = self;
	
	NSNumber *failedAttempts = [MittSaldoSettings getKeyLockFailedAttempts];
	if (failedAttempts != nil && [failedAttempts intValue] > 0) {
        keyLock.titleLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"KeyLockWrongCode", nil), 3 - [failedAttempts intValue]];
	}
	
    self.keyLockView = keyLock;
	self.window.backgroundColor = [UIColor blackColor];
	self.keyLockView.view.frame = [UIScreen mainScreen].applicationFrame;
    self.window.rootViewController = self.keyLockView;
}

- (void)validateKeyCombination:(NSArray *)keyCombination sender:(id)sender
{
	NSArray *storedKeyCombo = [MittSaldoSettings getKeyLockCombination];
	int storedKeyComboCount = [storedKeyCombo count];
	
	BOOL comboIsValid = storedKeyComboCount == [keyCombination count];
	
	if (comboIsValid) {
		for (int i = 0; i < storedKeyComboCount; i++) {
            comboIsValid = [storedKeyCombo objectAtIndex:i] == [keyCombination objectAtIndex:i];
			
            if (!comboIsValid)
                break;
		}
	}
	
	if (comboIsValid) {
		[self.keyLockView.view removeFromSuperview];
		self.window.rootViewController = self.navController;
		
		// Reset the attempts to log in		
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		self.keyLockView = nil;
	}
	else  {
		int attempt = [MittSaldoSettings getKeyLockFailedAttempts] != nil ? [[MittSaldoSettings getKeyLockFailedAttempts] intValue] : 0;

		// Increase the failed attempts to log in		 
		attempt++;
		[MittSaldoSettings setKeyLockFailedAttempts:attempt];
		
		if (attempt < 3) {
			[(BSKeyLock *)sender deemKeyCombinationInvalid];
			((KeyLockViewController *)self.keyLockView).titleLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"KeyLockWrongCode", nil), 3 - attempt];
		}
		else {
			// The user failed three times. Remove all settings and let them into the app
			[MittSaldoSettings resetAllPersonalInformation];		
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"KeyLockAuthenticationFailedTitle", nil) 
															message:NSLocalizedString(@"KeyLockAuthenticationFailedMessage", nil) 
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			[self.keyLockView.view removeFromSuperview];
			self.keyLockView = nil;
            self.window.rootViewController = self.navController;
		}
	}
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) managedObjectContext 
{	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MittSaldo" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

	// Complete url to our database file
	NSString *databaseFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"accounts.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath: databaseFilePath];
	
	NSError *error;
    
	// Set up options to allow a lightweight migration of data to the new model
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
															URL:storeUrl options:options error:&error]) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DBUpgradeFailedTitle", nil)
														message:NSLocalizedString(@"DBUpgradeFailedMessage", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
        
		
		// If the upgrade failed we remove the database file and create a new one. This should solve the problem :)		
		NSFileManager *fileManager = [NSFileManager defaultManager];
				
		if ([fileManager fileExistsAtPath:databaseFilePath]) {
			// Remove the file
			[fileManager removeItemAtPath:databaseFilePath error:nil];
			
			// Create a new empty database
			persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
			if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
				// Handle error
			}    
		}
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark - Application's documents directory

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark - Version updates

- (void)runVersionUpgrades
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (![settings valueForKey:@"updateDataModelForVersion3"]) {
        
        MSUpgradeV1ToV2 *upgrade = [[MSUpgradeV1ToV2 alloc] init];
        [upgrade upgrade];
        [upgrade release];
        [settings setValue:@"OK" forKey:@"updateDataModelForVersion3"];
        [settings synchronize];
    }
}

#pragma mark - Memory management

- (void)dealloc {
	[_keyLockView release];
    [_accountsController release];
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[_window release];
	[super dealloc];
}


@end

