//
//  Keychain.h
//  OpenStack
//
//  Based on KeychainWrapper in BadassVNC by Dylan Barrie
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject

+ (void)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)getStringForKey:(NSString *)key;

+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)forKey;

+ (void)removeValueForKey:(NSString *)key;

@end