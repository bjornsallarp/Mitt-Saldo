//
//  Created by Björn Sållarp on 2010-06-21.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol AccountParser<NSObject>
@required
-(BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
@property (nonatomic, assign) int accountsParsed;
@end
