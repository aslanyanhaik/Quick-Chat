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

#import <Foundation/Foundation.h>
#import "FSparseSnapshotTree.h"
#import "FNode.h"
#import "FCompoundWrite.h"
#import "FClock.h"

@interface FServerValues : NSObject

+ (NSDictionary*) generateServerValues:(id<FClock>)clock;
+ (id) resolveDeferredValueCompoundWrite:(FCompoundWrite*)write withServerValues:(NSDictionary*)serverValues;
+ (id<FNode>) resolveDeferredValueSnapshot:(id<FNode>)node withServerValues:(NSDictionary*)serverValues;
+ (id) resolveDeferredValueTree:(FSparseSnapshotTree*)tree withServerValues:(NSDictionary*)serverValues;

@end
