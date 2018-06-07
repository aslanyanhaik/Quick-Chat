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

#import "FIRPhoneAuthProvider.h"

#import <FirebaseCore/FIRLogger.h>
#import "FIRPhoneAuthCredential_Internal.h"
#import <FirebaseCore/FIRApp.h>
#import "FIRAuthAPNSToken.h"
#import "FIRAuthAPNSTokenManager.h"
#import "FIRAuthAppCredential.h"
#import "FIRAuthAppCredentialManager.h"
#import "FIRAuthGlobalWorkQueue.h"
#import "FIRAuth_Internal.h"
#import "FIRAuthURLPresenter.h"
#import "FIRAuthNotificationManager.h"
#import "FIRAuthErrorUtils.h"
#import "FIRAuthBackend.h"
#import "FIRAuthSettings.h"
#import "FIRAuthWebUtils.h"
#import "FirebaseAuthVersion.h"
#import <FirebaseCore/FIROptions.h>
#import "FIRGetProjectConfigRequest.h"
#import "FIRGetProjectConfigResponse.h"
#import "FIRSendVerificationCodeRequest.h"
#import "FIRSendVerificationCodeResponse.h"
#import "FIRVerifyClientRequest.h"
#import "FIRVerifyClientResponse.h"

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRReCAPTCHAURLCallBack
    @brief The callback invoked at the end of the flow to fetch a reCAPTCHA URL.
    @param reCAPTCHAURL The reCAPTCHA URL.
    @param error The error that occured while fetching the reCAPTCHAURL, if any.
 */
typedef void (^FIRReCAPTCHAURLCallBack)(NSURL *_Nullable reCAPTCHAURL, NSError *_Nullable error);

/** @typedef FIRVerifyClientCallback
    @brief The callback invoked at the end of a client verification flow.
    @param appCredential credential that proves the identity of the app during a phone
        authentication flow.
    @param error The error that occured while verifying the app, if any.
 */
typedef void (^FIRVerifyClientCallback)(FIRAuthAppCredential *_Nullable appCredential,
                                        NSError *_Nullable error);

/** @typedef FIRFetchAuthDomainCallback
    @brief The callback invoked at the end of the flow to fetch the Auth domain.
    @param authDomain The Auth domain.
    @param error The error that occured while fetching the auth domain, if any.
 */
typedef void (^FIRFetchAuthDomainCallback)(NSString *_Nullable authDomain,
                                           NSError *_Nullable error);
/** @var kAuthDomainSuffix
    @brief The suffix of the auth domain pertiaining to a given Firebase project.
 */
static NSString *const kAuthDomainSuffix = @"firebaseapp.com";

/** @var kauthTypeVerifyApp
    @brief The auth type to be specified in the app verification request.
 */
static NSString *const kAuthTypeVerifyApp = @"verifyApp";

/** @var kReCAPTCHAURLStringFormat
    @brief The format of the URL used to open the reCAPTCHA page during app verification.
 */
NSString *const kReCAPTCHAURLStringFormat = @"https://%@/__/auth/handler?";

@implementation FIRPhoneAuthProvider {

  /** @var _auth
      @brief The auth instance used for verifying the phone number.
   */
  FIRAuth *_auth;

  /** @var _callbackScheme
      @brief The callback URL scheme used for reCAPTCHA fallback.
   */
  NSString *_callbackScheme;
}

/** @fn initWithAuth:
    @brief returns an instance of @c FIRPhoneAuthProvider assocaited with the provided auth
          instance.
    @return An Instance of @c FIRPhoneAuthProvider.
   */
- (nullable instancetype)initWithAuth:(FIRAuth *)auth {
  self = [super init];
  if (self) {
    _auth = auth;
    _callbackScheme = [[[_auth.app.options.clientID componentsSeparatedByString:@"."]
        reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
  }
  return self;
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber
               UIDelegate:(nullable id<FIRAuthUIDelegate>)UIDelegate
               completion:(nullable FIRVerificationResultCallback)completion {
  if (![self isCallbackSchemeRegistered]) {
    [NSException raise:NSInternalInconsistencyException
                format:@"Please register custom URL scheme '%@' in the app's Info.plist file.",
                       _callbackScheme];
  }
  dispatch_async(FIRAuthGlobalWorkQueue(), ^{
    FIRVerificationResultCallback callBackOnMainThread = ^(NSString *_Nullable verificationID,
                                                           NSError *_Nullable error) {
      if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(verificationID, error);
        });
      }
    };
    [self internalVerifyPhoneNumber:phoneNumber completion:^(NSString *_Nullable verificationID,
                                                             NSError *_Nullable error) {
      if (!error) {
        callBackOnMainThread(verificationID, nil);
        return;
      }
      NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
      BOOL isInvalidAppCredential = error.code == FIRAuthErrorCodeInternalError &&
          underlyingError.code == FIRAuthErrorCodeInvalidAppCredential;
      if (error.code != FIRAuthErrorCodeMissingAppToken && !isInvalidAppCredential) {
        callBackOnMainThread(nil, error);
        return;
      }
      NSMutableString *eventID = [[NSMutableString alloc] init];
      for (int i=0; i<10; i++) {
        [eventID appendString:
            [NSString stringWithFormat:@"%c", 'a' + arc4random_uniform('z' - 'a' + 1)]];
      }
      [self reCAPTCHAURLWithEventID:eventID completion:^(NSURL *_Nullable reCAPTCHAURL,
                                                         NSError *_Nullable error) {
        if (error) {
          callBackOnMainThread(nil, error);
          return;
        }
        FIRAuthURLCallbackMatcher callbackMatcher = ^BOOL(NSURL *_Nullable callbackURL) {
          return [self isVerifyAppURL:callbackURL eventID:eventID];
        };
        [self->_auth.authURLPresenter presentURL:reCAPTCHAURL
                                      UIDelegate:UIDelegate
                                 callbackMatcher:callbackMatcher
                                      completion:^(NSURL *_Nullable callbackURL,
                                                   NSError *_Nullable error) {
          if (error) {
            callBackOnMainThread(nil, error);
            return;
          }
          NSError *reCAPTCHAError;
          NSString *reCAPTCHAToken = [self reCAPTCHATokenForURL:callbackURL error:&reCAPTCHAError];
          if (!reCAPTCHAToken) {
            callBackOnMainThread(nil, reCAPTCHAError);
            return;
          }
          FIRSendVerificationCodeRequest *request =
            [[FIRSendVerificationCodeRequest alloc] initWithPhoneNumber:phoneNumber
                                                          appCredential:nil
                                                         reCAPTCHAToken:reCAPTCHAToken
                                                   requestConfiguration:
                                                      self->_auth.requestConfiguration];
          [FIRAuthBackend sendVerificationCode:request
                                      callback:^(FIRSendVerificationCodeResponse
                                                 *_Nullable response, NSError *_Nullable error) {
            if (error) {
              callBackOnMainThread(nil, error);
              return;
            }
            callBackOnMainThread(response.verificationID, nil);
          }];
        }];
      }];
    }];
  });
}

- (FIRPhoneAuthCredential *)credentialWithVerificationID:(NSString *)verificationID
                                        verificationCode:(NSString *)verificationCode {
  return [[FIRPhoneAuthCredential alloc] initWithProviderID:FIRPhoneAuthProviderID
                                             verificationID:verificationID
                                           verificationCode:verificationCode];
}

+ (instancetype)provider {
  return [[self alloc]initWithAuth:[FIRAuth auth]];
}

+ (instancetype)providerWithAuth:(FIRAuth *)auth {
  return [[self alloc]initWithAuth:auth];
}

#pragma mark - Internal Methods

/** @fn isCallbackSchemeRegistered
    @brief Checks whether or not the expected callback scheme has been registered by the app.
    @remarks This method is thread-safe.
 */
- (BOOL)isCallbackSchemeRegistered {
  NSString *expectedCustomScheme = [_callbackScheme lowercaseString];
  NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
  for (NSDictionary *urlType in urlTypes) {
    NSArray *urlTypeSchemes = urlType[@"CFBundleURLSchemes"];
    for (NSString *urlTypeScheme in urlTypeSchemes) {
      if ([urlTypeScheme.lowercaseString isEqualToString:expectedCustomScheme]) {
        return YES;
      }
    }
  }
  return NO;
}

/** @fn reCAPTCHATokenForURL:error:
    @brief Parses the reCAPTCHA URL and returns.
    @param URL The url to be parsed for a reCAPTCHA token.
    @param error The error that occurred if any.
    @return The reCAPTCHA token if successful.
 */
- (NSString *)reCAPTCHATokenForURL:(NSURL *)URL error:(NSError **)error {
  NSURLComponents *actualURLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
  NSArray<NSURLQueryItem *> *queryItems = [actualURLComponents queryItems];
  NSString *deepLinkURL = [FIRAuthWebUtils queryItemValue:@"deep_link_id" from:queryItems];
  NSData *errorData;
  if (deepLinkURL) {
    actualURLComponents = [NSURLComponents componentsWithString:deepLinkURL];
    queryItems = [actualURLComponents queryItems];
    NSString *recaptchaToken = [FIRAuthWebUtils queryItemValue:@"recaptchaToken" from:queryItems];
    if (recaptchaToken) {
      return recaptchaToken;
    }
    NSString *firebaseError = [FIRAuthWebUtils queryItemValue:@"firebaseError" from:queryItems];
    errorData = [firebaseError dataUsingEncoding:NSUTF8StringEncoding];
  } else {
    errorData = nil;
  }
  NSError *jsonError;
  NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:errorData
                                                            options:0
                                                              error:&jsonError];
  if (jsonError) {
    *error = [FIRAuthErrorUtils JSONSerializationErrorWithUnderlyingError:jsonError];
    return nil;
  }
  *error = [FIRAuthErrorUtils URLResponseErrorWithCode:errorDict[@"code"]
                                               message:errorDict[@"message"]];
  if (!*error) {
    NSString *reason;
    if(errorDict[@"code"] && errorDict[@"message"]) {
      reason = [NSString stringWithFormat:@"[%@] - %@",errorDict[@"code"], errorDict[@"message"]];
    } else {
      reason = [NSString stringWithFormat:@"An unknown error occurred with the following "
          "response: %@", deepLinkURL];
    }
    *error = [FIRAuthErrorUtils appVerificationUserInteractionFailureWithReason:reason];
  }
  return nil;
}

/** @fn isVerifyAppURL:
    @brief Parses a URL into all available query items.
    @param URL The url to be checked against the authType string.
    @return Whether or not the URL matches authType.
 */
- (BOOL)isVerifyAppURL:(nullable NSURL *)URL eventID:(NSString *)eventID {
  if (!URL) {
    return NO;
  }
  NSURLComponents *actualURLComponents =
      [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
  actualURLComponents.query = nil;
  actualURLComponents.fragment = nil;

  NSURLComponents *expectedURLComponents = [NSURLComponents new];
  expectedURLComponents.scheme = _callbackScheme;
  expectedURLComponents.host = @"firebaseauth";
  expectedURLComponents.path = @"/link";

  if (!([[expectedURLComponents URL] isEqual:[actualURLComponents URL]])) {
    return NO;
  }
  actualURLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
  NSArray<NSURLQueryItem *> *queryItems = [actualURLComponents queryItems];
  NSString *deepLinkURL = [FIRAuthWebUtils queryItemValue:@"deep_link_id" from:queryItems];
  if (deepLinkURL == nil) {
    return NO;
  }
  NSURLComponents *deepLinkURLComponents = [NSURLComponents componentsWithString:deepLinkURL];
  NSArray<NSURLQueryItem *> *deepLinkQueryItems = [deepLinkURLComponents queryItems];

  NSString *deepLinkAuthType = [FIRAuthWebUtils queryItemValue:@"authType" from:deepLinkQueryItems];
  NSString *deepLinkEventID = [FIRAuthWebUtils queryItemValue:@"eventId" from:deepLinkQueryItems];
  if ([deepLinkAuthType isEqualToString:kAuthTypeVerifyApp] &&
      [deepLinkEventID isEqualToString:eventID]) {
    return YES;
  }
  return NO;
}

/** @fn internalVerifyPhoneNumber:completion:
    @brief Starts the phone number authentication flow by sending a verifcation code to the
        specified phone number.
    @param phoneNumber The phone number to be verified.
    @param completion The callback to be invoked when the verification flow is finished.
 */

- (void)internalVerifyPhoneNumber:(NSString *)phoneNumber
                       completion:(nullable FIRVerificationResultCallback)completion {
  if (!phoneNumber.length) {
    completion(nil, [FIRAuthErrorUtils missingPhoneNumberErrorWithMessage:nil]);
    return;
  }
  [_auth.notificationManager checkNotificationForwardingWithCallback:
      ^(BOOL isNotificationBeingForwarded) {
    if (!isNotificationBeingForwarded) {
      completion(nil, [FIRAuthErrorUtils notificationNotForwardedError]);
      return;
    }
    FIRVerificationResultCallback callback = ^(NSString *_Nullable verificationID,
                                               NSError *_Nullable error) {
      if (completion) {
        completion(verificationID, error);
      }
    };
    [self verifyClientAndSendVerificationCodeToPhoneNumber:phoneNumber
                               retryOnInvalidAppCredential:YES
                                                  callback:callback];
  }];
}

/** @fn verifyClientAndSendVerificationCodeToPhoneNumber:retryOnInvalidAppCredential:callback:
    @brief Starts the flow to verify the client via silent push notification.
    @param retryOnInvalidAppCredential Whether of not the flow should be retried if an
        FIRAuthErrorCodeInvalidAppCredential error is returned from the backend.
    @param phoneNumber The phone number to be verified.
    @param callback The callback to be invoked on the global work queue when the flow is
        finished.
 */
- (void)verifyClientAndSendVerificationCodeToPhoneNumber:(NSString *)phoneNumber
                             retryOnInvalidAppCredential:(BOOL)retryOnInvalidAppCredential
                                                callback:(FIRVerificationResultCallback)callback {
  if (_auth.settings.isAppVerificationDisabledForTesting) {
    FIRSendVerificationCodeRequest *request =
        [[FIRSendVerificationCodeRequest alloc] initWithPhoneNumber:phoneNumber
                                                     appCredential:nil
                                                    reCAPTCHAToken:nil
                                              requestConfiguration:
                                                  _auth.requestConfiguration];
    [FIRAuthBackend sendVerificationCode:request
                                callback:^(FIRSendVerificationCodeResponse *_Nullable response,
                                           NSError *_Nullable error) {
      callback(response.verificationID, error);
    }];
    return;
  }
  [self verifyClientWithCompletion:^(FIRAuthAppCredential *_Nullable appCredential,
                                     NSError *_Nullable error) {
    if (error) {
      callback(nil, error);
      return;
    }
    FIRSendVerificationCodeRequest *request =
        [[FIRSendVerificationCodeRequest alloc] initWithPhoneNumber:phoneNumber
                                                     appCredential:appCredential
                                                    reCAPTCHAToken:nil
                                              requestConfiguration:
                                                  self->_auth.requestConfiguration];
    [FIRAuthBackend sendVerificationCode:request
                                callback:^(FIRSendVerificationCodeResponse *_Nullable response,
                                           NSError *_Nullable error) {
      if (error) {
        if (error.code == FIRAuthErrorCodeInvalidAppCredential) {
          if (retryOnInvalidAppCredential) {
            [self->_auth.appCredentialManager clearCredential];
            [self verifyClientAndSendVerificationCodeToPhoneNumber:phoneNumber
                                       retryOnInvalidAppCredential:NO
                                                          callback:callback];
            return;
          }
          callback(nil, [FIRAuthErrorUtils unexpectedResponseWithDeserializedResponse:nil
                                                                      underlyingError:error]);
          return;
        }
        callback(nil, error);
        return;
      }
      callback(response.verificationID, nil);
    }];
  }];
}

/** @fn verifyClientWithCompletion:completion:
    @brief Continues the flow to verify the client via silent push notification.
    @param completion The callback to be invoked when the client verification flow is finished.
 */
- (void)verifyClientWithCompletion:(FIRVerifyClientCallback)completion {
  if (_auth.appCredentialManager.credential) {
    completion(_auth.appCredentialManager.credential, nil);
    return;
  }
  [_auth.tokenManager getTokenWithCallback:^(FIRAuthAPNSToken *_Nullable token,
                                             NSError *_Nullable error) {
    if (!token) {
      completion(nil, [FIRAuthErrorUtils missingAppTokenErrorWithUnderlyingError:error]);
      return;
    }
    FIRVerifyClientRequest *request =
        [[FIRVerifyClientRequest alloc] initWithAppToken:token.string
                                               isSandbox:token.type == FIRAuthAPNSTokenTypeSandbox
                                    requestConfiguration:self->_auth.requestConfiguration];
    [FIRAuthBackend verifyClient:request callback:^(FIRVerifyClientResponse *_Nullable response,
                                                    NSError *_Nullable error) {
      if (error) {
        completion(nil, error);
        return;
      }
      NSTimeInterval timeout = [response.suggestedTimeOutDate timeIntervalSinceNow];
      [self->_auth.appCredentialManager
          didStartVerificationWithReceipt:response.receipt
                                  timeout:timeout
                                 callback:^(FIRAuthAppCredential *credential) {
        if (!credential.secret) {
          FIRLogWarning(kFIRLoggerAuth, @"I-AUT000014",
                        @"Failed to receive remote notification to verify app identity within "
                        @"%.0f second(s)", timeout);
        }
        completion(credential, nil);
      }];
    }];
  }];
}

/** @fn reCAPTCHAURLWithEventID:completion:
    @brief Constructs a URL used for opening a reCAPTCHA app verification flow using a given event
        ID.
    @param eventID The event ID used for this purpose.
    @param completion The callback invoked after the URL has been constructed or an error
        has been encountered.
 */
- (void)reCAPTCHAURLWithEventID:(NSString *)eventID completion:(FIRReCAPTCHAURLCallBack)completion {
  [self fetchAuthDomainWithCompletion:^(NSString *_Nullable authDomain,
                                        NSError *_Nullable error) {
    if (error) {
      completion(nil, error);
      return;
    }
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSString *clientID = self->_auth.app.options.clientID;
    NSString *apiKey = self->_auth.requestConfiguration.APIKey;
    NSMutableArray<NSURLQueryItem *> *queryItems = [@[
      [NSURLQueryItem queryItemWithName:@"apiKey" value:apiKey],
      [NSURLQueryItem queryItemWithName:@"authType" value:kAuthTypeVerifyApp],
      [NSURLQueryItem queryItemWithName:@"ibi" value:bundleID ?: @""],
      [NSURLQueryItem queryItemWithName:@"clientId" value:clientID],
      [NSURLQueryItem queryItemWithName:@"v" value:[FIRAuthBackend authUserAgent]],
      [NSURLQueryItem queryItemWithName:@"eventId" value:eventID]
      ] mutableCopy
    ];

    if (self->_auth.requestConfiguration.languageCode) {
      [queryItems addObject:[NSURLQueryItem queryItemWithName:@"hl"value:
                             self->_auth.requestConfiguration.languageCode]];
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:
      [NSString stringWithFormat:kReCAPTCHAURLStringFormat, authDomain]];
    [components setQueryItems:queryItems];
    completion([components URL], nil);
  }];
}

/** @fn fetchAuthDomainWithCompletion:completion:
    @brief Fetches the auth domain associated with the Firebase Project.
    @param completion The callback invoked after the auth domain has been constructed or an error
        has been encountered.
 */
- (void)fetchAuthDomainWithCompletion:(FIRFetchAuthDomainCallback)completion {
  FIRGetProjectConfigRequest *request =
      [[FIRGetProjectConfigRequest alloc] initWithRequestConfiguration:_auth.requestConfiguration];

  [FIRAuthBackend getProjectConfig:request
                          callback:^(FIRGetProjectConfigResponse *_Nullable response,
                                     NSError *_Nullable error) {
    if (error) {
      completion(nil, error);
      return;
    }
    NSString *authDomain;
    for (NSString *domain in response.authorizedDomains) {
      NSInteger index = domain.length - kAuthDomainSuffix.length;
      if (index >= 2) {
        if ([domain hasSuffix:kAuthDomainSuffix] && domain.length >= kAuthDomainSuffix.length + 2) {
          authDomain = domain;
          break;
        }
      }
    }
    if (!authDomain.length) {
      completion(nil, [FIRAuthErrorUtils unexpectedErrorResponseWithDeserializedResponse:response]);
      return;
    }
    completion(authDomain, nil);
  }];
}

@end

NS_ASSUME_NONNULL_END
