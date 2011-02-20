//
//  LogEntry.h
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LogEntry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Content;
@property (nonatomic, retain) NSDate * DateAdded;
@property (nonatomic, retain) NSString * Bank;
@end





