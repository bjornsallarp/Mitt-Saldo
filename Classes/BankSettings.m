//
//  Created by Björn Sållarp on 2010-09-19.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BankSettings.h"


@implementation BankSettings
@synthesize bankIdentifier = bankIdentifier_;
@synthesize username = username_;
@synthesize password = password_;
@synthesize loginURL = loginURL_;
@synthesize requestTimeout = requestTimeout_;
@synthesize bookmarkedURL = boomarkedURL_;
@synthesize transferURL = transferURL_;
@synthesize accountsURL = accountsURL_;

#pragma mark - Initializers
+ (BankSettings *)settingsForBank:(NSString *)bankIdentifier
{
    return [[[self alloc] initWithBankIdentifier:bankIdentifier] autorelease];
}

- (id)initWithBankIdentifier:(NSString *)bankIdentifier
{
    if ((self = [self init])) {
        self.bankIdentifier = bankIdentifier;
        [self reloadSettings];
    }
    
    return self;
}

#pragma mark - Methods
- (void)reloadSettings
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.loginURL = [NSURL URLWithString:[settings valueForKey:[NSString stringWithFormat:@"%@Login", self.bankIdentifier]]];
	self.accountsURL = [NSURL URLWithString:[settings valueForKey:[NSString stringWithFormat:@"%@Accounts", self.bankIdentifier]]];
	self.transferURL = [NSURL URLWithString:[settings valueForKey:[NSString stringWithFormat:@"%@Transfer", self.bankIdentifier]]];
    
    if ([settings valueForKey:[NSString stringWithFormat:@"%@Bookmark", self.bankIdentifier]]) {
        self.bookmarkedURL = [NSURL URLWithString:[settings valueForKey:[NSString stringWithFormat:@"%@Bookmark", self.bankIdentifier]]];        
    }
    else {
        self.bookmarkedURL = nil;
    }  

    self.username = [settings valueForKey:[NSString stringWithFormat:@"%@_ssn_preference", self.bankIdentifier]];
    self.password = [settings valueForKey:[NSString stringWithFormat:@"%@_pwd_preference", self.bankIdentifier]];
}

- (void)save
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:self.username forKey:[NSString stringWithFormat:@"%@_ssn_preference", self.bankIdentifier]];
    [settings setValue:self.password forKey:[NSString stringWithFormat:@"%@_pwd_preference", self.bankIdentifier]];
    [settings setValue:[boomarkedURL_ absoluteString] forKey:[NSString stringWithFormat:@"%@Bookmark", self.bankIdentifier]];

    [settings synchronize];
}

#pragma mark - Accessors
- (NSURL *)bookmarkedURL
{
    // Return bookmarked if it exists
    return (boomarkedURL_ != nil) ? boomarkedURL_ : self.transferURL;
}

#pragma mark - Memory management
-(void)dealloc
{
    self.transferURL = nil;
    self.bookmarkedURL = nil;
    self.accountsURL = nil;
	self.bankIdentifier = nil;
	self.username = nil;
	self.password = nil;
	self.loginURL = nil;
    self.accountsURL = nil;
    
	[super dealloc];
}
@end
