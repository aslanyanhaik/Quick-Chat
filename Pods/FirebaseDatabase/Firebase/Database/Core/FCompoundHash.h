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

#import "FNode.h"


@interface FCompoundHashBuilder : NSObject

- (FPath *)currentPath;

@end


typedef BOOL (^FCompoundHashSplitStrategy) (FCompoundHashBuilder *builder);


@interface FCompoundHash : NSObject

@property (nonatomic, strong, readonly) NSArray *posts;
@property (nonatomic, strong, readonly) NSArray *hashes;

+ (FCompoundHash *)fromNode:(id<FNode>)node;
+ (FCompoundHash *)fromNode:(id<FNode>)node splitStrategy:(FCompoundHashSplitStrategy)strategy;

@end
