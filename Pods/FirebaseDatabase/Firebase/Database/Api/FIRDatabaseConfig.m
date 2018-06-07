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

#import <FirebaseCore/FIRApp.h>
#import "FIRDatabaseConfig.h"
#import "FIRDatabaseConfig_Private.h"
#import "FIRNoopAuthTokenProvider.h"
#import "FAuthTokenProvider.h"

@interface FIRDatabaseConfig (Private)

@property (nonatomic, strong, readwrite) NSString *sessionIdentifier;

@end

@implementation FIRDatabaseConfig

- (id)init {
    [NSException raise:NSInvalidArgumentException format:@"Can't create config objects!"];
    return nil;
}

- (id)initWithSessionIdentifier:(NSString *)identifier authTokenProvider:(id<FAuthTokenProvider>)authTokenProvider {
    self = [super init];
    if (self != nil) {
        self->_sessionIdentifier = identifier;
        self->_callbackQueue = dispatch_get_main_queue();
        self->_persistenceCacheSizeBytes = 10*1024*1024; // Default cache size is 10MB
        self->_authTokenProvider = authTokenProvider;
    }
    return self;
}

- (void)assertUnfrozen {
    if (self.isFrozen) {
        [NSException raise:NSGenericException format:@"Can't modify config objects after they are in use for FIRDatabaseReferences."];
    }
}

- (void)setAuthTokenProvider:(id<FAuthTokenProvider>)authTokenProvider {
    [self assertUnfrozen];
    self->_authTokenProvider = authTokenProvider;
}

- (void)setPersistenceEnabled:(BOOL)persistenceEnabled {
    [self assertUnfrozen];
    self->_persistenceEnabled = persistenceEnabled;
}

- (void)setPersistenceCacheSizeBytes:(NSUInteger)persistenceCacheSizeBytes {
    [self assertUnfrozen];
    // Can't be less than 1MB
    if (persistenceCacheSizeBytes < 1024*1024) {
        [NSException raise:NSInvalidArgumentException format:@"The minimum cache size must be at least 1MB"];
    }
    if (persistenceCacheSizeBytes > 100*1024*1024) {
        [NSException raise:NSInvalidArgumentException format:@"Firebase Database currently doesn't support a cache size larger than 100MB"];
    }
    self->_persistenceCacheSizeBytes = persistenceCacheSizeBytes;
}

- (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    [self assertUnfrozen];
    self->_callbackQueue = callbackQueue;
}

- (void)freeze {
    self->_isFrozen = YES;
}

// TODO: Only used for tests.  Migrate to FIRDatabase and remove.
+ (FIRDatabaseConfig *)defaultConfig {
    static dispatch_once_t onceToken;
    static FIRDatabaseConfig *defaultConfig;
    dispatch_once(&onceToken, ^{
        defaultConfig = [FIRDatabaseConfig configForName:@"default"];
    });
    return defaultConfig;
}

// TODO: This is only used for tests.  We should fix them to go through FIRDatabase and remove
// this method and the sessionsConfigs dictionary (FIRDatabase automatically creates one config per app).
+ (FIRDatabaseConfig *)configForName:(NSString *)name {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9-_]+$" options:0 error:nil];
    if ([expression numberOfMatchesInString:name options:0 range:NSMakeRange(0, name.length)] == 0) {
        [NSException raise:NSInvalidArgumentException format:@"Name can only contain [a-zA-Z0-9-_]"];
    }

    static dispatch_once_t onceToken;
    static NSMutableDictionary *sessionConfigs;
    dispatch_once(&onceToken, ^{
        sessionConfigs = [NSMutableDictionary dictionary];
    });
    @synchronized(sessionConfigs) {
        if (!sessionConfigs[name]) {
            id<FAuthTokenProvider> authTokenProvider = [FAuthTokenProvider authTokenProviderForApp:[FIRApp defaultApp]];
            sessionConfigs[name] = [[FIRDatabaseConfig alloc] initWithSessionIdentifier:name
                                                                      authTokenProvider:authTokenProvider];
        }
        return sessionConfigs[name];
    }
}

@end
