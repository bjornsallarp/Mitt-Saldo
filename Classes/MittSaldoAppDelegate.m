//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "MittSaldoAppDelegate.h"
#import "RootViewController.h"
#import "KeyLockViewController.h"
#import "MyMutableURLRequest.h"
@implementation MittSaldoAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootView, tabController, settingsView, webView;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// If it's an iPad we need to modify the default user agent. Unfortunately the UIWebView (at least in iPad 3.2.2)
	// reports a different user agent than the Safari browser which cause problems with Handelsbanken.
	if(IDIOM == IPAD)
	{
		[NSMutableURLRequest setupUserAgentOverwrite];
	}
    
	application.applicationSupportsShakeToEdit = YES;
		
	// Override point for customization after app launch    
	NSManagedObjectContext *context = [self managedObjectContext];
	
	if (!context) {
        NSLog(@"Error initializing object model context");
		exit(-1);
    }
	
	// We're not using undo. By setting it to nil we reduce the memory footprint of the app
	[context setUndoManager:nil];
	
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	WebViewUserAgent *agent = [[WebViewUserAgent alloc] init];
	[settings setObject:[agent userAgentString] forKey:@"WebViewUserAgent"];
	[agent release];

	[MittSaldoSettings loadStandardSettings];

	if([MittSaldoSettings isKeyLockActive])
	{
		[self openKeyLockView];
	}
	else 
	{
		[window addSubview:[tabController view]];
		
		// If no banks has been configured we move the user directly to the settings page
		if([[MittSaldoSettings configuredBanks] count] == 0)
		{
			tabController.selectedIndex = 2;
		}
	}


    [window makeKeyAndVisible];
	
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
	if([MittSaldoSettings isKeyLockActive] && keyLockView == nil)
	{
		// remove the main application from view otherwise the user 
		// will get a glimps of it when the application resume
		[self.tabController.view removeFromSuperview];
	}
	
	// Store the date and time for when the application enter background mode
	[MittSaldoSettings setApplicationDidEnterBackground:[NSDate date]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSDate *backgroundDate = [MittSaldoSettings getApplicationDidEnterBackground];
	
	// Time difference between when the application was closed and now
	NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:backgroundDate];
	
	// If keylock is activated we want to present it if the application was closed for more than configured time
	if([MittSaldoSettings isKeyLockActive] && keyLockView == nil && diff > [MittSaldoSettings multitaskingTimeout])
	{
		// And open key lock
		[self openKeyLockView];
	}
	
	
	// Remove all authentication cookies if the application was closed for more than 30 seconds.
	// bank cookies don't live for very long (they are session cookies).
	if(diff > 30)
	{
		NSArray *banks = [MittSaldoSettings supportedBanks];
		
		for(NSString *bankId in banks)
		{
			[MittSaldoSettings removeCookiesForBank:bankId];
		}
	}
	
	// If the key lock wasn't opened, we move the application view back onto the window
	if(keyLockView == nil && [MittSaldoSettings isKeyLockActive])
	{
		[window addSubview:[self.tabController view]];
	}
}


// Triggers when the app goes into sleep mode due to inactivity or the on/off button
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// use the same code as for multitasking
    [self applicationWillEnterForeground:application];
}

// Triggers when the app comes back from sleep mode
- (void)applicationWillResignActive:(UIApplication *)application
{
	// use the same code as for multitasking
    [self applicationDidEnterBackground:application];
}

#pragma mark -
#pragma mark Key lock methods

-(void)openKeyLockView
{	
	keyLockView = [[KeyLockViewController alloc] initWithNibName:@"KeyLockViewController" bundle:[NSBundle mainBundle] headerText:nil];
	keyLockView.appDelegate = self;
	keyLockView.view.frame = CGRectOffset(keyLockView.view.frame, 0.0, 20.0);
	
	NSNumber *failedAttempts = [MittSaldoSettings getKeyLockFailedAttempts];
	if(failedAttempts != nil)
	{
		if([failedAttempts intValue] > 0)
		{
			keyLockView.titleLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"KeyLockWrongCode", nil), 3 - [failedAttempts intValue]];
		}
	}
	
	window.backgroundColor = [UIColor blackColor];

	if(window.frame.size.width > 320)
	{
		CGRect keyRect = keyLockView.view.frame;
		
		keyRect.origin.y = (window.frame.size.height - keyLockView.view.frame.size.height) / 2;
		keyRect.origin.x = (window.frame.size.width - keyLockView.view.frame.size.width) / 2;
		
		keyLockView.view.frame = keyRect;
	}
	
	[window addSubview:[keyLockView view]];
}

-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender
{
	NSArray *storedKeyCombo = [MittSaldoSettings getKeyLockCombination];
	int storedKeyComboCount = [storedKeyCombo count];
	
	BOOL comboIsValid = storedKeyComboCount == [keyCombination count];
	
	if (comboIsValid)
	{
		for (int i = 0; i < storedKeyComboCount; i++) {
			if([storedKeyCombo objectAtIndex:i] != [keyCombination objectAtIndex:i])
			{
				comboIsValid = NO;
				break;
			}
		}
	}
	
	if(comboIsValid)
	{
		[[keyLockView view] removeFromSuperview];
		[window addSubview:[tabController view]];
		
		// Reset the attempts to log in		
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[keyLockView release];
		keyLockView = nil;
	}
	else 
	{
		int attempt = 0;
		if([MittSaldoSettings getKeyLockFailedAttempts] != nil) 
		{
			attempt = [[MittSaldoSettings getKeyLockFailedAttempts] intValue];
		}

		// Increase the failed attempts to log in		 
		attempt++;
		[MittSaldoSettings setKeyLockFailedAttempts:attempt];
		
		if(attempt < 3)
		{
			[(BSKeyLock*)sender deemKeyCombinationInvalid];
			keyLockView.titleLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"KeyLockWrongCode", nil), 3 - attempt];
		}
		else 
		{
			// The user failed three times. Remove all settings and let them into the app
			[MittSaldoSettings resetAllPersonalInformation];
			
			NSArray *accounts = [CoreDataHelper getObjectsFromContext:@"Account" 
															  sortKey:@"accountid" 
														sortAscending:NO 
												 managedObjectContext:self.managedObjectContext];
			
			int accountsCount = [accounts count];
			
			for (int i = 0; i < accountsCount; i++) {
				[managedObjectContext deleteObject:[accounts objectAtIndex:i]];
			}
			
			NSError * error;
			// Store the objects
			if (![managedObjectContext save:&error]) {
				
				// Handle the error. OR not...
				NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
			}
			
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"KeyLockAuthenticationFailedTitle", nil) 
															message:NSLocalizedString(@"KeyLockAuthenticationFailedMessage", nil) 
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			[[keyLockView view] removeFromSuperview];
			[window addSubview:[tabController view]];
			[keyLockView release];
			keyLockView = nil;
		}
	}
}


#pragma mark -
#pragma mark Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
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


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MittSaldo" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    //managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
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
		NSLog(@"Error: %@", [error userInfo]);
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DBUpgradeFailedTitle", nil)
														message:NSLocalizedString(@"DBUpgradeFailedMessage", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		// If the upgrade failed we remove the database file and create a new one. This should solve the problem :)		
		NSFileManager *fileManager = [NSFileManager defaultManager];
				
		if([fileManager fileExistsAtPath:databaseFilePath])
		{
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


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[keyLockView release];
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[rootView release];
	[settingsView release];
	[webView release];
	[tabController release];
	
	[window release];
	[super dealloc];
}


@end

