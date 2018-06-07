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

#import "FIRFacebookAuthCredential.h"

#import "FIRFacebookAuthProvider.h"
#import "FIRAuthExceptionUtils.h"
#import "FIRVerifyAssertionRequest.h"

@interface FIRFacebookAuthCredential ()

- (nullable instancetype)initWithProvider:(NSString *)provider NS_UNAVAILABLE;

@end

@implementation FIRFacebookAuthCredential {
  NSString *_accessToken;
}

- (nullable instancetype)initWithProvider:(NSString *)provider {
  [FIRAuthExceptionUtils raiseMethodNotImplementedExceptionWithReason:
      @"Please call the designated initializer."];
  return nil;
}

- (nullable instancetype)initWithAccessToken:(NSString *)accessToken {
  self = [super initWithProvider:FIRFacebookAuthProviderID];
  if (self) {
    _accessToken = [accessToken copy];
  }
  return self;
}

- (void)prepareVerifyAssertionRequest:(FIRVerifyAssertionRequest *)request {
  request.providerAccessToken = _accessToken;
}

@end
