//
//  IKANOLoginParser.h
//  MittSaldo
//
//  Created by Björn Sållarp on 5/26/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IkanoLoginParser : NSObject<NSXMLParserDelegate>  
@property (nonatomic, retain) NSMutableDictionary *hiddenFields;
@property (nonatomic, retain) NSString *ssnFieldName;
@property (nonatomic, retain) NSString *passwordFieldName;

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error;
@end
