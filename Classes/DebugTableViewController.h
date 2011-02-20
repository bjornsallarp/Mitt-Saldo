//
//  DebugTableViewController.h
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface DebugTableViewController : UIViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate> {
	IBOutlet UITableView *debugTableView;
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
