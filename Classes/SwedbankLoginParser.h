//
//  SwedbankLoginParser.h
//  MittSaldo
//
//  Created by Björn Sållarp on 4/12/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SwedbankLoginParser : NSObject {
	NSString *csrf_token;
	NSString *usernameField;
	NSString *passwordField;
    NSString *nextLoginStepUrl;
}

@property (nonatomic, retain) NSString *csrf_token;
@property (nonatomic, retain) NSString *usernameField;
@property (nonatomic, retain) NSString *passwordField;
@property (nonatomic, retain) NSString *nextLoginStepUrl;

-(BOOL)parseXMLData:(NSData *)data parseError:(NSError **)error;

@end
