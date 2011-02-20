//
//  LogEntryClass.m
//  MittSaldo
//
//  Created by Anna Berntsson on 2010-10-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LogEntryClass.h"



@implementation LogEntryClass
@synthesize Bank, DateAdded, Content;


-(void)appendStep:(NSString*)stepName logContent:(NSString*)logContent
{

	if(self.Content == nil)
	{
		self.Content = [NSString stringWithFormat:@"STEP: %@\n%@", stepName, logContent];
	}
	else 
	{
		self.Content = [NSString stringWithFormat:@"\n\nSTEP: %@\n%@", stepName, logContent];
	}
}


-(void)dealloc
{
	[Content release];
	[DateAdded release];
	[Bank release];
	[super dealloc];
}

@end