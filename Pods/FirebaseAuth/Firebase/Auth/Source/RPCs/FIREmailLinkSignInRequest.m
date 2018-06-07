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

#import "FIREmailLinkSignInRequest.h"

/** @var kEmailLinkSigninEndpoint
    @brief The "EmailLinkSignin" endpoint.
 */
static NSString *const kEmailLinkSigninEndpoint = @"emailLinkSignin";

/** @var kEmailKey
    @brief The key for the "identifier" value in the request.
 */
static NSString *const kEmailKey = @"email";

/** @var kEmailLinkKey
    @brief The key for the "emailLink" value in the request.
 */
static NSString *const kOOBCodeKey = @"oobCode";

/** @var kIDTokenKey
    @brief The key for the "IDToken" value in the request.
 */
static NSString *const kIDTokenKey = @"idToken";

/** @var kPostBodyKey
    @brief The key for the "postBody" value in the request.
 */
static NSString *const kPostBodyKey = @"postBody";

@implementation FIREmailLinkSignInRequest

- (instancetype)initWithEmail:(NSString *)email
                      oobCode:(NSString *)oobCode
         requestConfiguration:(FIRAuthRequestConfiguration *)requestConfiguration {
  self = [super initWithEndpoint:kEmailLinkSigninEndpoint
            requestConfiguration:requestConfiguration];
  if (self) {
    _email = email;
    _oobCode = oobCode;
  }
  return self;
}

- (nullable id)unencodedHTTPRequestBodyWithError:(NSError *_Nullable *_Nullable)error {
  NSMutableDictionary *postBody = [@{
    kEmailKey : _email,
    kOOBCodeKey : _oobCode,
  } mutableCopy];

  if (_IDToken) {
    postBody[kIDTokenKey] = _IDToken;
  }
  return postBody;
}

@end
