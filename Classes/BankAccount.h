//
//  Created by Björn Sållarp on 2010-05-16.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <CoreData/CoreData.h>


@interface BankAccount :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * bankIdentifier;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * displayAccount;
@property (nonatomic, retain) NSNumber * accountid;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSNumber * availableAmount;

@end



