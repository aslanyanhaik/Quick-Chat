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

#import "FIRStoragePath.h"

NS_ASSUME_NONNULL_BEGIN

@interface FIRStorageReference ()

@property(nonatomic, readwrite) FIRStorage *storage;

/**
 * The current path which points to an object in the Google Cloud Storage bucket.
 */
@property(strong, nonatomic) FIRStoragePath *path;

- (instancetype)initWithStorage:(FIRStorage *)storage
                           path:(FIRStoragePath *)path NS_DESIGNATED_INITIALIZER;

- (NSString *)stringValue;

@end

NS_ASSUME_NONNULL_END
