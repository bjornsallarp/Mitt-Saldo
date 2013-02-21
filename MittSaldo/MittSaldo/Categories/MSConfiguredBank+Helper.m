//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//

#import "MSConfiguredBank+Helper.h"
#import "Keychain.h"

@implementation MSConfiguredBank (Helper)

+ (MSConfiguredBank *)insertNewBankWithName:(NSString *)name bankIdentifier:(NSString *)bankIdentifier
{
    MSConfiguredBank *newBank = [NSManagedObjectContext insertEntityForName:@"MSConfiguredBank"];
    
    newBank.name = name;
    newBank.bankIdentifier = bankIdentifier;
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef guid = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    newBank.guid = (NSString *)guid;
    CFRelease(guid);
    
    return newBank;
}

#pragma mark - Accessors

- (NSString *)ssn
{
    return [Keychain getStringForKey:[NSString stringWithFormat:@"%@_ssn", self.guid]];
}

- (NSString *)password
{
    return [Keychain getStringForKey:[NSString stringWithFormat:@"%@_pwd", self.guid]];    
}

- (void)setSsn:(NSString *)ssn
{
    if (ssn == nil) {
        [Keychain removeValueForKey:[NSString stringWithFormat:@"%@_ssn", self.guid]];
    }
    else {
        [Keychain setString:ssn forKey:[NSString stringWithFormat:@"%@_ssn", self.guid]];        
    }
}

- (void)setPassword:(NSString *)password
{
    if (password == nil) {
        [Keychain removeValueForKey:[NSString stringWithFormat:@"%@_pwd", self.guid]];
    }
    else {
        [Keychain setString:password forKey:[NSString stringWithFormat:@"%@_pwd", self.guid]];
    }
}

@end
