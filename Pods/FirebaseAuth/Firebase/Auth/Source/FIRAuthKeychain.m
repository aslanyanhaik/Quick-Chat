/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FIRAuthKeychain.h"

#import <Security/Security.h>

#import "FIRAuthErrorUtils.h"
#import "FIRAuthUserDefaultsStorage.h"

#if FIRAUTH_USER_DEFAULTS_STORAGE_AVAILABLE
#import <UIKit/UIKit.h>

/** @var kOSVersionMatcherForUsingUserDefaults
    @brief The regular expression to match all OS versions that @c FIRAuthUserDefaultsStorage is
        used instead if available.
 */
static NSString *const kOSVersionMatcherForUsingUserDefaults = @"^10\\.[01](\\..*)?$";

#endif  // FIRAUTH_USER_DEFAULTS_STORAGE_AVAILABLE

/** @var kAccountPrefix
    @brief The prefix string for keychain item account attribute before the key.
    @remarks A number "1" is encoded in the prefix in case we need to upgrade the scheme in future.
 */
static NSString *const kAccountPrefix = @"firebase_auth_1_";

@implementation FIRAuthKeychain {
  /** @var _service
      @brief The name of the keychain service.
   */
  NSString *_service;

  /** @var _legacyItemDeletedForKey
      @brief Indicates whether or not this class knows that the legacy item for a particular key has
          been deleted.
      @remarks This dictionary is to avoid unecessary keychain operations against legacy items.
   */
  NSMutableDictionary *_legacyEntryDeletedForKey;
}

- (id<FIRAuthStorage>)initWithService:(NSString *)service {

#if FIRAUTH_USER_DEFAULTS_STORAGE_AVAILABLE

  NSString *OSVersion = [UIDevice currentDevice].systemVersion;
  NSRegularExpression *regex =
      [NSRegularExpression regularExpressionWithPattern:kOSVersionMatcherForUsingUserDefaults
                                                options:0
                                                  error:NULL];
  if ([regex numberOfMatchesInString:OSVersion options:0 range:NSMakeRange(0, OSVersion.length)]) {
    return (id<FIRAuthStorage>)[[FIRAuthUserDefaultsStorage alloc] initWithService:service];
  }

#endif  // FIRAUTH_USER_DEFAULTS_STORAGE_AVAILABLE

  self = [super init];
  if (self) {
    _service = [service copy];
    _legacyEntryDeletedForKey = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (NSData *)dataForKey:(NSString *)key error:(NSError **_Nullable)error {
  if (!key.length) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@", @"The key cannot be nil or empty."];
    return nil;
  }
  NSData *data = [self itemWithQuery:[self genericPasswordQueryWithKey:key] error:error];
  if (error && *error) {
    return nil;
  }
  if (data) {
    return data;
  }
  // Check for legacy form.
  if (_legacyEntryDeletedForKey[key]) {
    return nil;
  }
  data = [self itemWithQuery:[self legacyGenericPasswordQueryWithKey:key] error:error];
  if (error && *error) {
    return nil;
  }
  if (!data) {
    // Mark legacy data as non-existing so we don't have to query it again.
    _legacyEntryDeletedForKey[key] = @YES;
    return nil;
  }
  // Move the data to current form.
  if (![self setData:data forKey:key error:error]) {
    return nil;
  }
  [self deleteLegacyItemWithKey:key];
  return data;
}

- (BOOL)setData:(NSData *)data forKey:(NSString *)key error:(NSError **_Nullable)error {
  if (!key.length) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@", @"The key cannot be nil or empty."];
    return NO;
  }
  NSDictionary *attributes = @{
    (__bridge id)kSecValueData : data,
    (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
  };
  return [self setItemWithQuery:[self genericPasswordQueryWithKey:key]
                     attributes:attributes
                          error:error];
}

- (BOOL)removeDataForKey:(NSString *)key error:(NSError **_Nullable)error {
  if (!key.length) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@", @"The key cannot be nil or empty."];
    return NO;
  }
  if (![self deleteItemWithQuery:[self genericPasswordQueryWithKey:key] error:error]) {
    return NO;
  }
  // Legacy form item, if exists, also needs to be removed, otherwise it will be exposed when
  // current form item is removed, leading to incorrect semantics.
  [self deleteLegacyItemWithKey:key];
  return YES;
}

#pragma mark - Private

- (NSData *)itemWithQuery:(NSDictionary *)query error:(NSError **_Nullable)error {
  NSMutableDictionary *returningQuery = [query mutableCopy];
  returningQuery[(__bridge id)kSecReturnData] = @YES;
  returningQuery[(__bridge id)kSecReturnAttributes] = @YES;
  // Using a match limit of 2 means that we can check whether there is more than one item.
  // If we used a match limit of 1 we would never find out.
  returningQuery[(__bridge id)kSecMatchLimit] = @2;

  CFArrayRef result = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)returningQuery,
                                        (CFTypeRef *)&result);

  if (status == noErr && result != NULL) {
   NSArray *items = (__bridge_transfer NSArray *)result;
    if (items.count != 1) {
      if (error) {
        *error = [FIRAuthErrorUtils keychainErrorWithFunction:@"SecItemCopyMatching"
                                                       status:status];
      }
      return nil;
    }

    if (error) {
      *error = nil;
    }
    NSDictionary *item = items[0];
    return item[(__bridge id)kSecValueData];
  }

  if (status == errSecItemNotFound) {
    if (error) {
      *error = nil;
    }
  } else {
    if (error) {
      *error = [FIRAuthErrorUtils keychainErrorWithFunction:@"SecItemCopyMatching" status:status];
    }
  }
  return nil;
}

- (BOOL)setItemWithQuery:(NSDictionary *)query
              attributes:(NSDictionary *)attributes
                   error:(NSError **_Nullable)error {
  NSMutableDictionary *combined = [attributes mutableCopy];
  [combined addEntriesFromDictionary:query];
  BOOL hasItem = NO;
  OSStatus status = SecItemAdd((__bridge CFDictionaryRef)combined, NULL);

  if (status == errSecDuplicateItem) {
    hasItem = YES;
    status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
  }

  if (status == noErr) {
    return YES;
  }
  if (error) {
    NSString *function = hasItem ? @"SecItemUpdate" : @"SecItemAdd";
    *error = [FIRAuthErrorUtils keychainErrorWithFunction:function status:status];
  }
  return NO;
}

- (BOOL)deleteItemWithQuery:(NSDictionary *)query error:(NSError **_Nullable)error {
  OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
  if (status == noErr || status == errSecItemNotFound) {
    return YES;
  }
  if (error) {
    *error = [FIRAuthErrorUtils keychainErrorWithFunction:@"SecItemDelete" status:status];
  }
  return NO;
}

/** @fn deleteLegacyItemsWithKey:
    @brief Deletes legacy item from the keychain if it is not already known to be deleted.
    @param key The key for the item.
 */
- (void)deleteLegacyItemWithKey:(NSString *)key {
  if (_legacyEntryDeletedForKey[key]) {
    return;
  }
  NSDictionary *query = [self legacyGenericPasswordQueryWithKey:key];
  SecItemDelete((__bridge CFDictionaryRef)query);
  _legacyEntryDeletedForKey[key] = @YES;
}

/** @fn genericPasswordQueryWithKey:
    @brief Returns a keychain query of generic password to be used to manipulate key'ed value.
    @param key The key for the value being manipulated, used as the account field in the query.
 */
- (NSDictionary *)genericPasswordQueryWithKey:(NSString *)key {
  return @{
    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrAccount : [kAccountPrefix stringByAppendingString:key],
    (__bridge id)kSecAttrService : _service,
  };
}

/** @fn legacyGenericPasswordQueryWithKey:
    @brief Returns a keychain query of generic password without service field, which is used by
        previous version of this class.
    @param key The key for the value being manipulated, used as the account field in the query.
 */
- (NSDictionary *)legacyGenericPasswordQueryWithKey:(NSString *)key {
  return @{
    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrAccount : key,
  };
}

@end
