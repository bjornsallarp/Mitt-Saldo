//
//  Keychain.m
//  OpenStack
//
//  Based on KeychainWrapper in BadassVNC by Dylan Barrie
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Keychain.h"
#import <Security/Security.h>

static NSString *kKeychainPrefix = @"Mitt Saldo";

@implementation Keychain

+ (void)setString:(NSString *)string forKey:(NSString *)key 
{
    key = [NSString stringWithFormat:@"%@ - %@", kKeychainPrefix, key];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
	// First check if it already exists, by creating a search dictionary and requesting that 
    // nothing be returned, and performing the search anyway.
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	[existsQueryDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[existsQueryDictionary setObject:@"service" forKey:(id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(id)kSecAttrAccount];

    OSStatus res = SecItemCopyMatching((CFDictionaryRef)existsQueryDictionary, NULL);
    
	if (res == errSecItemNotFound) {
		NSMutableDictionary *addDict = existsQueryDictionary;
		[addDict setObject:data forKey:(id)kSecValueData];
        SecItemAdd((CFDictionaryRef)addDict, NULL);
	} else if (res == errSecSuccess) {
		NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:data forKey:(id)kSecValueData];
		SecItemUpdate((CFDictionaryRef)existsQueryDictionary, (CFDictionaryRef)attributeDict);
	} else {
		debug_NSLog(@"setString SecItemCopyMatching returned %ld!", res);
	}
}

+ (NSString *)getStringForKey:(NSString *)key 
{  
    key = [NSString stringWithFormat:@"%@ - %@", kKeychainPrefix, key];
    
	NSMutableDictionary *existsQueryDictionary = [NSMutableDictionary dictionary];
	[existsQueryDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[existsQueryDictionary setObject:@"service" forKey:(id)kSecAttrService];
	[existsQueryDictionary setObject:key forKey:(id)kSecAttrAccount];
	[existsQueryDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
	// We want the data back!
	NSData *data = nil;
	
	OSStatus res = SecItemCopyMatching((CFDictionaryRef)existsQueryDictionary, (CFTypeRef *)&data);
	[data autorelease];
	if (res == errSecSuccess) {
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	} 
    else if (res != errSecItemNotFound) {
		debug_NSLog(@"getStringForKey SecItemCopyMatching returned %ld!", res);
	}		
	
	return nil;
}

+ (void)setObject:(id)object forKey:(NSString *)forKey
{
    NSString *key = [NSString stringWithFormat:@"%@ - %@", kKeychainPrefix, forKey];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];
     
    OSStatus res = SecItemCopyMatching((CFDictionaryRef)keychainQuery, NULL);
    if (res == errSecItemNotFound) {
        NSMutableDictionary *addDict = keychainQuery;
        [addDict setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(id)kSecValueData];
        res = SecItemAdd((CFDictionaryRef)addDict, NULL);
        debug_NSLog(@"SecItemAdd returned %ld! for key: %@, class: %@", res, key, [object class]);
    } 
    else if (res == errSecSuccess) {
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:(id)kSecValueData];
		SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)attributeDict);
    }
    else {
        debug_NSLog(@"setObject SecItemCopyMatching returned %ld!", res);
    }
}

+ (id)objectForKey:(NSString *)forKey
{
    NSString *key = [NSString stringWithFormat:@"%@ - %@", kKeychainPrefix, forKey];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];

    NSData *storedData = nil;
    
    OSStatus res = SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&storedData);
    [storedData autorelease];
    if (res == errSecSuccess) {
       return [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
    }
    else if (res != errSecItemNotFound) {
        debug_NSLog(@"getObject SecItemCopyMatching returned %ld!", res);
    }
    
    return nil;
}

+ (void)removeValueForKey:(NSString *)forKey
{
    NSString *key = [NSString stringWithFormat:@"%@ - %@", kKeychainPrefix, forKey];
    
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionary];
    [keychainQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainQuery setObject:@"service" forKey:(id)kSecAttrService];
    [keychainQuery setObject:key forKey:(id)kSecAttrAccount];
    
    OSStatus result = SecItemDelete((CFDictionaryRef)keychainQuery);
    
    if (result != errSecSuccess) {
        debug_NSLog(@"removeValueForKey SecItemDelete returned %ld! For key: %@", result, forKey);        
    }
}

@end