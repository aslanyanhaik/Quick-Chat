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

#import "FIRAuthBackend.h"

#import "FIRAuthErrorUtils.h"
#import "FIRAuthGlobalWorkQueue.h"
#import "FirebaseAuth.h"
#import "FIRAuthRPCRequest.h"
#import "FIRAuthRPCResponse.h"
#import "FIRCreateAuthURIRequest.h"
#import "FIRCreateAuthURIResponse.h"
#import "FIRDeleteAccountRequest.h"
#import "FIRDeleteAccountResponse.h"
#import "FIRGetAccountInfoRequest.h"
#import "FIRGetAccountInfoResponse.h"
#import "FIRGetOOBConfirmationCodeRequest.h"
#import "FIRGetOOBConfirmationCodeResponse.h"
#import "FIRGetProjectConfigRequest.h"
#import "FIRGetProjectConfigResponse.h"
#import "FIRResetPasswordRequest.h"
#import "FIRResetPasswordResponse.h"
#import "FIRSendVerificationCodeRequest.h"
#import "FIRSendVerificationCodeResponse.h"
#import "FIRSecureTokenRequest.h"
#import "FIRSecureTokenResponse.h"
#import "FIRSetAccountInfoRequest.h"
#import "FIRSetAccountInfoResponse.h"
#import "FIRSignUpNewUserRequest.h"
#import "FIRSignUpNewUserResponse.h"
#import "FIRVerifyAssertionRequest.h"
#import "FIRVerifyAssertionResponse.h"
#import "FIRVerifyClientRequest.h"
#import "FIRVerifyClientResponse.h"
#import "FIRVerifyCustomTokenRequest.h"
#import "FIRVerifyCustomTokenResponse.h"
#import "FIRVerifyPasswordRequest.h"
#import "FIRVerifyPasswordResponse.h"
#import "FIREmailLinkSignInRequest.h"
#import "FIREmailLinkSignInResponse.h"
#import "FIRVerifyPhoneNumberRequest.h"
#import "FIRVerifyPhoneNumberResponse.h"
#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import <GTMSessionFetcher/GTMSessionFetcherService.h>

#if TARGET_OS_IOS
#import "../AuthProviders/Phone/FIRPhoneAuthCredential_Internal.h"
#import "FIRPhoneAuthProvider.h"
#endif

/** @var kClientVersionHeader
    @brief HTTP header name for the client version.
 */
static NSString *const kClientVersionHeader = @"X-Client-Version";

/** @var kIosBundleIdentifierHeader
    @brief HTTP header name for iOS bundle ID.
 */
static NSString *const kIosBundleIdentifierHeader = @"X-Ios-Bundle-Identifier";

/** @var kFirebaseLocalHeader
    @brief HTTP header name for the firebase locale.
 */
static NSString *const kFirebaseLocalHeader = @"X-Firebase-Locale";

/** @var kFirebaseAuthCoreFrameworkMarker
    @brief The marker in the HTTP header that indicates the request comes from Firebase Auth Core.
 */
static NSString *const kFirebaseAuthCoreFrameworkMarker = @"FirebaseCore-iOS";

/** @var kJSONContentType
    @brief The value of the HTTP content-type header for JSON payloads.
 */
static NSString *const kJSONContentType = @"application/json";

/** @var kErrorDataKey
    @brief Key for error data in NSError returned by @c GTMSessionFetcher.
 */
static NSString * const kErrorDataKey = @"data";

/** @var kErrorKey
    @brief The key for the "error" value in JSON responses from the server.
 */
static NSString *const kErrorKey = @"error";

/** @var kErrorsKey
    @brief The key for the "errors" value in JSON responses from the server.
 */
static NSString *const kErrorsKey = @"errors";

/** @var kReasonKey
    @brief The key for the "reason" value in JSON responses from the server.
 */
static NSString *const kReasonKey = @"reason";

/** @var kInvalidKeyReasonValue
    @brief The value for the "reason" key indicating an invalid API Key was received by the server.
 */
static NSString *const kInvalidKeyReasonValue = @"keyInvalid";

/** @var kAppNotAuthorizedReasonValue
    @brief The value for the "reason" key indicating the App is not authorized to use Firebase
        Authentication.
 */
static NSString *const kAppNotAuthorizedReasonValue = @"ipRefererBlocked";

/** @var kErrorMessageKey
    @brief The key for an error's "message" value in JSON responses from the server.
 */
static NSString *const kErrorMessageKey = @"message";

/** @var kUserNotFoundErrorMessage
    @brief This is the error message returned when the user is not found, which means the user
        account has been deleted given the token was once valid.
 */
static NSString *const kUserNotFoundErrorMessage = @"USER_NOT_FOUND";

/** @var kUserDeletedErrorMessage
    @brief This is the error message the server will respond with if the user entered an invalid
        email address.
 */
static NSString *const kUserDeletedErrorMessage = @"EMAIL_NOT_FOUND";

/** @var kInvalidLocalIDErrorMessage
    @brief This is the error message the server responds with if the user local id in the id token
        does not exit.
 */
static NSString *const kInvalidLocalIDErrorMessage = @"INVALID_LOCAL_ID";

/** @var kUserTokenExpiredErrorMessage
    @brief The error returned by the server if the token issue time is older than the account's
        valid_since time.
 */
static NSString *const kUserTokenExpiredErrorMessage = @"TOKEN_EXPIRED";

/** @var kTooManyRequestsErrorMessage
    @brief This is the error message the server will respond with if too many requests were made to
        a server method.
 */
static NSString *const kTooManyRequestsErrorMessage = @"TOO_MANY_ATTEMPTS_TRY_LATER";

/** @var kInvalidTokenCustomErrorMessage
    @brief This is the error message the server will respond with if there is a validation error
        with the custom token.
 */
static NSString *const kInvalidCustomTokenErrorMessage = @"INVALID_CUSTOM_TOKEN";

/** @var kCustomTokenMismatch
    @brief This is the error message the server will respond with if the service account and API key
        belong to different projects.
 */
static NSString *const kCustomTokenMismatch = @"CREDENTIAL_MISMATCH";

/** @var kInvalidCredentialErrorMessage
    @brief This is the error message the server responds with if the IDP token or requestUri is
        invalid.
 */
static NSString *const kInvalidCredentialErrorMessage = @"INVALID_IDP_RESPONSE";

/** @var kUserDisabledErrorMessage
    @brief The error returned by the server if the user account is diabled.
 */
static NSString *const kUserDisabledErrorMessage = @"USER_DISABLED";

/** @var kOperationNotAllowedErrorMessage
    @brief This is the error message the server will respond with if Admin disables IDP specified by
        provider.
 */
static NSString *const kOperationNotAllowedErrorMessage = @"OPERATION_NOT_ALLOWED";

/** @var kPasswordLoginDisabledErrorMessage
    @brief This is the error message the server responds with if password login is disabled.
 */
static NSString *const kPasswordLoginDisabledErrorMessage = @"PASSWORD_LOGIN_DISABLED";

/** @var kEmailAlreadyInUseErrorMessage
    @brief This is the error message the server responds with if the email address already exists.
 */
static NSString *const kEmailAlreadyInUseErrorMessage = @"EMAIL_EXISTS";

/** @var kInvalidEmailErrorMessage
    @brief The error returned by the server if the email is invalid.
 */
static NSString *const kInvalidEmailErrorMessage = @"INVALID_EMAIL";

/** @var kInvalidIdentifierErrorMessage
    @brief The error returned by the server if the identifier is invalid.
 */
static NSString *const kInvalidIdentifierErrorMessage = @"INVALID_IDENTIFIER";

/** @var kWrongPasswordErrorMessage
    @brief This is the error message the server will respond with if the user entered a wrong
        password.
 */
static NSString *const kWrongPasswordErrorMessage = @"INVALID_PASSWORD";

/** @var kCredentialTooOldErrorMessage
    @brief This is the error message the server responds with if account change is attempted 5
        minutes after signing in.
 */
static NSString *const kCredentialTooOldErrorMessage = @"CREDENTIAL_TOO_OLD_LOGIN_AGAIN";

/** @var kFederatedUserIDAlreadyLinkedMessage
    @brief This is the error message the server will respond with if the federated user ID has been
        already linked with another account.
 */
static NSString *const kFederatedUserIDAlreadyLinkedMessage = @"FEDERATED_USER_ID_ALREADY_LINKED";

/** @var kInvalidUserTokenErrorMessage
    @brief This is the error message the server responds with if user's saved auth credential is
        invalid, and the user needs to sign in again.
 */
static NSString *const kInvalidUserTokenErrorMessage = @"INVALID_ID_TOKEN";

/** @var kWeakPasswordErrorMessagePrefix
    @brief This is the prefix for the error message the server responds with if user's new password
        to be set is too weak.
 */
static NSString *const kWeakPasswordErrorMessagePrefix = @"WEAK_PASSWORD";

/** @var kExpiredActionCodeErrorMessage
    @brief This is the error message the server will respond with if the action code is expired.
 */
static NSString *const kExpiredActionCodeErrorMessage = @"EXPIRED_OOB_CODE";

/** @var kInvalidActionCodeErrorMessage
    @brief This is the error message the server will respond with if the action code is invalid.
 */
static NSString *const kInvalidActionCodeErrorMessage = @"INVALID_OOB_CODE";

/** @var kMissingEmailErrorMessage
    @brief This is the error message the server will respond with if the email address is missing
        during a "send password reset email" attempt.
 */
static NSString *const kMissingEmailErrorMessage = @"MISSING_EMAIL";

/** @var kInvalidSenderEmailErrorMessage
    @brief This is the error message the server will respond with if the sender email is invalid
        during a "send password reset email" attempt.
 */
static NSString *const kInvalidSenderEmailErrorMessage = @"INVALID_SENDER";

/** @var kInvalidMessagePayloadErrorMessage
    @brief This is the error message the server will respond with if there are invalid parameters in
        the payload during a "send password reset email" attempt.
 */
static NSString *const kInvalidMessagePayloadErrorMessage = @"INVALID_MESSAGE_PAYLOAD";

/** @var kInvalidRecipientEmailErrorMessage
    @brief This is the error message the server will respond with if the recipient email is invalid.
 */
static NSString *const kInvalidRecipientEmailErrorMessage = @"INVALID_RECIPIENT_EMAIL";

/** @var kMissingIosBundleIDErrorMessage
    @brief This is the error message the server will respond with if iOS bundle ID is missing but
        the iOS App store ID is provided.
 */
static NSString *const kMissingIosBundleIDErrorMessage = @"MISSING_IOS_BUNDLE_ID";

/** @var kMissingAndroidPackageNameErrorMessage
    @brief This is the error message the server will respond with if Android Package Name is missing
        but the flag indicating the app should be installed is set to true.
 */
static NSString *const kMissingAndroidPackageNameErrorMessage = @"MISSING_ANDROID_PACKAGE_NAME";

/** @var kUnauthorizedDomainErrorMessage
    @brief This is the error message the server will respond with if the domain of the continue URL
        specified is not whitelisted in the firebase console.
 */
static NSString *const kUnauthorizedDomainErrorMessage = @"UNAUTHORIZED_DOMAIN";

/** @var kInvalidContinueURIErrorMessage
    @brief This is the error message the server will respond with if the continue URL provided in
        the request is invalid.
 */
static NSString *const kInvalidContinueURIErrorMessage = @"INVALID_CONTINUE_URI";

/** @var kMissingContinueURIErrorMessage
    @brief This is the error message the server will respond with if there was no continue URI
        present in a request that required one.
 */
static NSString *const kMissingContinueURIErrorMessage = @"MISSING_CONTINUE_URI";

/** @var kInvalidPhoneNumberErrorMessage
    @brief This is the error message the server will respond with if an incorrectly formatted phone
        number is provided.
 */
static NSString *const kInvalidPhoneNumberErrorMessage = @"INVALID_PHONE_NUMBER";

/** @var kInvalidVerificationCodeErrorMessage
    @brief This is the error message the server will respond with if an invalid verification code is
        provided.
 */
static NSString *const kInvalidVerificationCodeErrorMessage = @"INVALID_CODE";

/** @var kInvalidSessionInfoErrorMessage
    @brief This is the error message the server will respond with if an invalid session info
        (verification ID) is provided.
 */
static NSString *const kInvalidSessionInfoErrorMessage = @"INVALID_SESSION_INFO";

/** @var kSessionExpiredErrorMessage
    @brief This is the error message the server will respond with if the SMS code has expired before
        it is used.
 */
static NSString *const kSessionExpiredErrorMessage = @"SESSION_EXPIRED";

/** @var kMissingAppTokenErrorMessage
    @brief This is the error message the server will respond with if the APNS token is missing in a
        verifyClient request.
 */
static NSString *const kMissingAppTokenErrorMessage = @"MISSING_IOS_APP_TOKEN";

/** @var kMissingAppCredentialErrorMessage
    @brief This is the error message the server will respond with if the app token is missing in a
        sendVerificationCode request.
 */
static NSString *const kMissingAppCredentialErrorMessage = @"MISSING_APP_CREDENTIAL";

/** @var kInvalidAppCredentialErrorMessage
    @brief This is the error message the server will respond with if the app credential in a
        sendVerificationCode request is invalid.
 */
static NSString *const kInvalidAppCredentialErrorMessage = @"INVALID_APP_CREDENTIAL";

/** @var kQuoutaExceededErrorMessage
    @brief This is the error message the server will respond with if the quota for SMS text messages
        has been exceeded for the project.
 */
static NSString *const kQuoutaExceededErrorMessage = @"QUOTA_EXCEEDED";

/** @var kAppNotVerifiedErrorMessage
    @brief This is the error message the server will respond with if Firebase could not verify the
        app during a phone authentication flow.
 */
static NSString *const kAppNotVerifiedErrorMessage = @"APP_NOT_VERIFIED";

/** @var kMissingClientIdentifier
    @brief This is the error message the server will respond with if Firebase could not verify the
        app during a phone authentication flow when a real phone number is used and app verification
        is disabled for testing.
 */
static NSString *const kMissingClientIdentifier = @"MISSING_CLIENT_IDENTIFIER";

/** @var kCaptchaCheckFailedErrorMessage
    @brief This is the error message the server will respond with if the reCAPTCHA token provided is
        invalid.
 */
static NSString *const kCaptchaCheckFailedErrorMessage = @"CAPTCHA_CHECK_FAILED";

/** @var gBackendImplementation
    @brief The singleton FIRAuthBackendImplementation instance to use.
 */
static id<FIRAuthBackendImplementation> gBackendImplementation;

/** @class FIRAuthBackendRPCImplementation
    @brief The default RPC-based backend implementation.
 */
@interface FIRAuthBackendRPCImplementation : NSObject <FIRAuthBackendImplementation>

/** @property RPCIssuer
    @brief An instance of FIRAuthBackendRPCIssuer for making RPC requests. Allows the RPC
        requests/responses to be easily faked.
 */
@property(nonatomic, strong) id<FIRAuthBackendRPCIssuer> RPCIssuer;

@end

@implementation FIRAuthBackend

+ (id<FIRAuthBackendImplementation>)implementation {
  if (!gBackendImplementation) {
    gBackendImplementation = [[FIRAuthBackendRPCImplementation alloc] init];
  }
  return gBackendImplementation;
}

+ (void)setBackendImplementation:(id<FIRAuthBackendImplementation>)backendImplementation {
  gBackendImplementation = backendImplementation;
}

+ (void)setDefaultBackendImplementationWithRPCIssuer:
    (nullable id<FIRAuthBackendRPCIssuer>)RPCIssuer {
  FIRAuthBackendRPCImplementation *defaultImplementation =
      [[FIRAuthBackendRPCImplementation alloc] init];
  if (RPCIssuer) {
    defaultImplementation.RPCIssuer = RPCIssuer;
  }
  gBackendImplementation = defaultImplementation;
}

+ (void)createAuthURI:(FIRCreateAuthURIRequest *)request
             callback:(FIRCreateAuthURIResponseCallback)callback {
  [[self implementation] createAuthURI:request callback:callback];
}

+ (void)getAccountInfo:(FIRGetAccountInfoRequest *)request
              callback:(FIRGetAccountInfoResponseCallback)callback {
  [[self implementation] getAccountInfo:request callback:callback];
}

+ (void)getProjectConfig:(FIRGetProjectConfigRequest *)request
                callback:(FIRGetProjectConfigResponseCallback)callback {
  [[self implementation] getProjectConfig:request callback:callback];
}

+ (void)setAccountInfo:(FIRSetAccountInfoRequest *)request
              callback:(FIRSetAccountInfoResponseCallback)callback {
  [[self implementation] setAccountInfo:request callback:callback];
}

+ (void)verifyAssertion:(FIRVerifyAssertionRequest *)request
               callback:(FIRVerifyAssertionResponseCallback)callback {
  [[self implementation] verifyAssertion:request callback:callback];
}

+ (void)verifyCustomToken:(FIRVerifyCustomTokenRequest *)request
                 callback:(FIRVerifyCustomTokenResponseCallback)callback {
  [[self implementation] verifyCustomToken:request callback:callback];
}

+ (void)verifyPassword:(FIRVerifyPasswordRequest *)request
              callback:(FIRVerifyPasswordResponseCallback)callback {
  [[self implementation] verifyPassword:request callback:callback];
}

+ (void)emailLinkSignin:(FIREmailLinkSignInRequest *)request
               callback:(FIREmailLinkSigninResponseCallback)callback {
  [[self implementation] emailLinkSignin:request callback:callback];
}

+ (void)secureToken:(FIRSecureTokenRequest *)request
           callback:(FIRSecureTokenResponseCallback)callback {
  [[self implementation] secureToken:request callback:callback];
}

+ (void)getOOBConfirmationCode:(FIRGetOOBConfirmationCodeRequest *)request
                      callback:(FIRGetOOBConfirmationCodeResponseCallback)callback {
  [[self implementation] getOOBConfirmationCode:request callback:callback];
}

+ (void)signUpNewUser:(FIRSignUpNewUserRequest *)request
             callback:(FIRSignupNewUserCallback)callback {
  [[self implementation] signUpNewUser:request callback:callback];
}

+ (void)deleteAccount:(FIRDeleteAccountRequest *)request callback:(FIRDeleteCallBack)callback {
  [[self implementation] deleteAccount:request callback:callback];
}

#if TARGET_OS_IOS
+ (void)sendVerificationCode:(FIRSendVerificationCodeRequest *)request
                    callback:(FIRSendVerificationCodeResponseCallback)callback {
  [[self implementation] sendVerificationCode:request callback:callback];
}

+ (void)verifyPhoneNumber:(FIRVerifyPhoneNumberRequest *)request
                 callback:(FIRVerifyPhoneNumberResponseCallback)callback {
  [[self implementation] verifyPhoneNumber:request callback:callback];
}

+ (void)verifyClient:(id)request callback:(FIRVerifyClientResponseCallback)callback {
  [[self implementation] verifyClient:request callback:callback];
}
#endif

+ (void)resetPassword:(FIRResetPasswordRequest *)request
             callback:(FIRResetPasswordCallback)callback {
  [[self implementation] resetPassword:request callback:callback];
}

+ (NSString *)authUserAgent {
  return [NSString stringWithFormat:@"FirebaseAuth.iOS/%s %@",
      FirebaseAuthVersionStr, GTMFetcherStandardUserAgentString(nil)];
}

@end

@interface FIRAuthBackendRPCIssuerImplementation : NSObject <FIRAuthBackendRPCIssuer>
@end

@implementation FIRAuthBackendRPCIssuerImplementation {
  /** @var The session fetcher service.
   */
  GTMSessionFetcherService *_fetcherService;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _fetcherService = [[GTMSessionFetcherService alloc] init];
    _fetcherService.userAgent = [FIRAuthBackend authUserAgent];
    _fetcherService.callbackQueue = FIRAuthGlobalWorkQueue();
  }
  return self;
}

- (void)asyncPostToURLWithRequestConfiguration:(FIRAuthRequestConfiguration *)requestConfiguration
                                           URL:(NSURL *)URL
                                          body:(NSData *)body
                                   contentType:(NSString *)contentType
                             completionHandler:(void (^)(NSData *_Nullable,
                               NSError *_Nullable))handler {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
  NSString *additionalFrameworkMarker = requestConfiguration.additionalFrameworkMarker ?:
      kFirebaseAuthCoreFrameworkMarker;
  NSString *clientVersion = [NSString stringWithFormat:@"iOS/FirebaseSDK/%s/%@",
                                                       FirebaseAuthVersionStr,
                                                       additionalFrameworkMarker];
  [request setValue:clientVersion forHTTPHeaderField:kClientVersionHeader];
  NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
  [request setValue:bundleID forHTTPHeaderField:kIosBundleIdentifierHeader];

  NSArray<NSString *> *preferredLocalizations = [NSBundle mainBundle].preferredLocalizations;
  if (preferredLocalizations.count) {
    NSString *acceptLanguage = preferredLocalizations.firstObject;
    [request setValue:acceptLanguage forHTTPHeaderField:@"Accept-Language"];
  }
  NSString *languageCode = requestConfiguration.languageCode;
  if (languageCode.length) {
    [request setValue:languageCode forHTTPHeaderField:kFirebaseLocalHeader];
  }
  GTMSessionFetcher* fetcher = [_fetcherService fetcherWithRequest:request];
  fetcher.bodyData = body;
  [fetcher beginFetchWithCompletionHandler:handler];
}

@end

@implementation FIRAuthBackendRPCImplementation

- (instancetype)init {
  self = [super init];
  if (self) {
    _RPCIssuer = [[FIRAuthBackendRPCIssuerImplementation alloc] init];
  }
  return self;
}

- (void)createAuthURI:(FIRCreateAuthURIRequest *)request
             callback:(FIRCreateAuthURIResponseCallback)callback {
  FIRCreateAuthURIResponse *response = [[FIRCreateAuthURIResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)getAccountInfo:(FIRGetAccountInfoRequest *)request
              callback:(FIRGetAccountInfoResponseCallback)callback {
  FIRGetAccountInfoResponse *response = [[FIRGetAccountInfoResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)getProjectConfig:(FIRGetProjectConfigRequest *)request
                callback:(FIRGetProjectConfigResponseCallback)callback {
  FIRGetProjectConfigResponse *response = [[FIRGetProjectConfigResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)setAccountInfo:(FIRSetAccountInfoRequest *)request
              callback:(FIRSetAccountInfoResponseCallback)callback {
  FIRSetAccountInfoResponse *response = [[FIRSetAccountInfoResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)verifyAssertion:(FIRVerifyAssertionRequest *)request
               callback:(FIRVerifyAssertionResponseCallback)callback {
  FIRVerifyAssertionResponse *response = [[FIRVerifyAssertionResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
      return;
    }
    callback(response, nil);
  }];
}

- (void)verifyCustomToken:(FIRVerifyCustomTokenRequest *)request
                 callback:(FIRVerifyCustomTokenResponseCallback)callback {
  FIRVerifyCustomTokenResponse *response = [[FIRVerifyCustomTokenResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)verifyPassword:(FIRVerifyPasswordRequest *)request
              callback:(FIRVerifyPasswordResponseCallback)callback {
  FIRVerifyPasswordResponse *response = [[FIRVerifyPasswordResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)emailLinkSignin:(FIREmailLinkSignInRequest *)request
               callback:(FIREmailLinkSigninResponseCallback)callback {
  FIREmailLinkSignInResponse *response = [[FIREmailLinkSignInResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)secureToken:(FIRSecureTokenRequest *)request
           callback:(FIRSecureTokenResponseCallback)callback {
  FIRSecureTokenResponse *response = [[FIRSecureTokenResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)getOOBConfirmationCode:(FIRGetOOBConfirmationCodeRequest *)request
                      callback:(FIRGetOOBConfirmationCodeResponseCallback)callback {
  FIRGetOOBConfirmationCodeResponse *response = [[FIRGetOOBConfirmationCodeResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)signUpNewUser:(FIRSignUpNewUserRequest *)request
             callback:(FIRSignupNewUserCallback)callback{
  FIRSignUpNewUserResponse *response  = [[FIRSignUpNewUserResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, nil);
    }
  }];
}

- (void)deleteAccount:(FIRDeleteAccountRequest *)request callback:(FIRDeleteCallBack)callback {
  FIRDeleteAccountResponse *response = [[FIRDeleteAccountResponse alloc] init];
  [self postWithRequest:request response:response callback:callback];
}

#if TARGET_OS_IOS
- (void)sendVerificationCode:(FIRSendVerificationCodeRequest *)request
                    callback:(FIRSendVerificationCodeResponseCallback)callback {
  FIRSendVerificationCodeResponse *response = [[FIRSendVerificationCodeResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
    } else {
      callback(response, error);
    }
  }];
}

- (void)verifyPhoneNumber:(FIRVerifyPhoneNumberRequest *)request
                 callback:(FIRVerifyPhoneNumberResponseCallback)callback {
  FIRVerifyPhoneNumberResponse *response = [[FIRVerifyPhoneNumberResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
      return;
    }
    // Check whether or not the successful response is actually the special case phone auth flow
    // that returns a temporary proof and phone number.
    if (response.phoneNumber.length && response.temporaryProof.length) {
      FIRPhoneAuthCredential *credential =
          [[FIRPhoneAuthCredential alloc] initWithTemporaryProof:response.temporaryProof
                                                     phoneNumber:response.phoneNumber
                                                      providerID:FIRPhoneAuthProviderID];
      callback(nil,
               [FIRAuthErrorUtils credentialAlreadyInUseErrorWithMessage:nil
                                                              credential:credential]);
      return;
    }
    callback(response, nil);
  }];
}

- (void)verifyClient:(id)request callback:(FIRVerifyClientResponseCallback)callback {
  FIRVerifyClientResponse *response = [[FIRVerifyClientResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
      return;
    }
    callback(response, nil);
  }];
}
#endif

- (void)resetPassword:(FIRResetPasswordRequest *)request
             callback:(FIRResetPasswordCallback)callback {
  FIRResetPasswordResponse *response = [[FIRResetPasswordResponse alloc] init];
  [self postWithRequest:request response:response callback:^(NSError *error) {
    if (error) {
      callback(nil, error);
      return;
    }
    callback(response, nil);
  }];
}

#pragma mark - Generic RPC handling methods

/** @fn postWithRequest:response:callback:
    @brief Calls the RPC using HTTP POST.
    @remarks Possible error responses:
        @see FIRAuthInternalErrorCodeRPCRequestEncodingError
        @see FIRAuthInternalErrorCodeJSONSerializationError
        @see FIRAuthInternalErrorCodeNetworkError
        @see FIRAuthInternalErrorCodeUnexpectedErrorResponse
        @see FIRAuthInternalErrorCodeUnexpectedResponse
        @see FIRAuthInternalErrorCodeRPCResponseDecodingError
    @param request The request.
    @param response The empty response to be filled.
    @param callback The callback for both success and failure.
 */
- (void)postWithRequest:(id<FIRAuthRPCRequest>)request
               response:(id<FIRAuthRPCResponse>)response
               callback:(void (^)(NSError *error))callback {
  NSError *error;
  NSData *bodyData;
  if ([request containsPostBody]) {
    id postBody = [request unencodedHTTPRequestBodyWithError:&error];
    if (!postBody) {
      callback([FIRAuthErrorUtils RPCRequestEncodingErrorWithUnderlyingError:error]);
      return;
    }

    NSJSONWritingOptions JSONWritingOptions = 0;
    #if DEBUG
      JSONWritingOptions |= NSJSONWritingPrettyPrinted;
    #endif

    if ([NSJSONSerialization isValidJSONObject:postBody]) {
      bodyData = [NSJSONSerialization dataWithJSONObject:postBody
                                                 options:JSONWritingOptions
                                                   error:&error];
      if (!bodyData) {
        // This is an untested case. This happens exclusively when there is an error in the framework
        // implementation of dataWithJSONObject:options:error:. This shouldn't normally occur as
        // isValidJSONObject: should return NO in any case we should encounter an error.
        error = [FIRAuthErrorUtils JSONSerializationErrorWithUnderlyingError:error];
      }
    } else {
      error = [FIRAuthErrorUtils JSONSerializationErrorForUnencodableType];
    }
    if (!bodyData) {
      callback(error);
      return;
    }
  }

  [_RPCIssuer asyncPostToURLWithRequestConfiguration:[request requestConfiguration]
                                                 URL:[request requestURL]
                                                body:bodyData
                                         contentType:kJSONContentType
                                   completionHandler:^(NSData *data, NSError *error) {
    // If there is an error with no body data at all, then this must be a network error.
    if (error && !data) {
      callback([FIRAuthErrorUtils networkErrorWithUnderlyingError:error]);
      return;
    }

    // Try to decode the HTTP response data which may contain either a successful response or error
    // message.
    NSError *jsonError;
    NSDictionary * dictionary =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableLeaves
                                          error:&jsonError];
    if (!dictionary) {
      if (error) {
        // We have an error, but we couldn't decode the body, so we have no additional information
        // other than the raw response and the original NSError (the jsonError is infered by the
        // error code (FIRAuthErrorCodeUnexpectedHTTPResponse, and is irrelevant.)
        callback([FIRAuthErrorUtils unexpectedErrorResponseWithData:data underlyingError:error]);
      } else {
        // This is supposed to be a "successful" response, but we couldn't deserialize the body.
        callback([FIRAuthErrorUtils unexpectedResponseWithData:data underlyingError:jsonError]);
      }
      return;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
      if (error) {
        callback([FIRAuthErrorUtils unexpectedErrorResponseWithDeserializedResponse:dictionary]);
      } else {
        callback([FIRAuthErrorUtils unexpectedResponseWithDeserializedResponse:dictionary]);
      }
      return;
    }

    // At this point we either have an error with successfully decoded details in the body, or we
    // have a response which must pass further validation before we know it's truly successful.
    // We deal with the case where we have an error with successfully decoded error details first:
    if (error) {
      NSDictionary *errorDictionary = dictionary[kErrorKey];
      if ([errorDictionary isKindOfClass:[NSDictionary class]]) {
        id<NSObject> errorMessage = errorDictionary[kErrorMessageKey];
        if ([errorMessage isKindOfClass:[NSString class]]) {
          NSString *errorMessageString = (NSString *)errorMessage;

          // Contruct client error.
          NSError *clientError = [[self class] clientErrorWithServerErrorMessage:errorMessageString
                                                                 errorDictionary:errorDictionary
                                                                        response:response];
          if (clientError) {
            callback(clientError);
            return;
          }
        }
        // Not a message we know, return the message directly.
        if (errorMessage) {
          NSError *unexpecterErrorResponse =
              [FIRAuthErrorUtils unexpectedErrorResponseWithDeserializedResponse:errorDictionary];
          callback(unexpecterErrorResponse);
          return;
        }
      }
      // No error message at all, return the decoded response.
      callback([FIRAuthErrorUtils unexpectedErrorResponseWithDeserializedResponse:dictionary]);
      return;
    }

    // Finally, we try to populate the response object with the JSON values.
    if (![response setWithDictionary:dictionary error:&error]) {
      callback([FIRAuthErrorUtils RPCResponseDecodingErrorWithDeserializedResponse:dictionary
                                                                   underlyingError:error]);
      return;
    }

    // Success! The response object originally passed in can be used by the caller.
    callback(nil);
  }];
}

/** @fn clientErrorWithServerErrorMessage:errorDictionary:
    @brief Translates known server errors to client errors.
    @param serverErrorMessage The error message from the server.
    @param errorDictionary The error part of the response from the server.
    @param response The response from the server RPC.
    @return A client error, if any.
 */
+ (nullable NSError *)clientErrorWithServerErrorMessage:(NSString *)serverErrorMessage
                                        errorDictionary:(NSDictionary *)errorDictionary
                                               response:(id<FIRAuthRPCResponse>)response {
  NSString *shortErrorMessage = serverErrorMessage;
  NSString *serverDetailErrorMessage;
  NSRange colonRange = [serverErrorMessage rangeOfString:@":"];
  if (colonRange.location != NSNotFound) {
    shortErrorMessage = [serverErrorMessage substringToIndex:colonRange.location];
    shortErrorMessage =
        [shortErrorMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    serverDetailErrorMessage = [serverErrorMessage substringFromIndex:colonRange.location + 1];
    serverDetailErrorMessage = [serverDetailErrorMessage stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
  }

  // Delegate the responsibility for constructing the client error to the response object,
  // if possible.
  SEL clientErrorWithServerErrorMessageSelector =
      @selector(clientErrorWithShortErrorMessage:detailErrorMessage:);
  if ([response respondsToSelector:clientErrorWithServerErrorMessageSelector]) {
    NSError *error = [response clientErrorWithShortErrorMessage:shortErrorMessage
                                             detailErrorMessage:serverDetailErrorMessage];
    if (error) {
      return error;
    }
  }

  if ([shortErrorMessage isEqualToString:kUserNotFoundErrorMessage]) {
    return [FIRAuthErrorUtils userNotFoundErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kUserDeletedErrorMessage]) {
    return [FIRAuthErrorUtils userNotFoundErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidLocalIDErrorMessage]) {
    // This case shouldn't be necessary but it is for now: b/27908364 .
    return [FIRAuthErrorUtils userNotFoundErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kUserTokenExpiredErrorMessage]) {
    return [FIRAuthErrorUtils userTokenExpiredErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kTooManyRequestsErrorMessage]) {
    return [FIRAuthErrorUtils tooManyRequestsErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidCustomTokenErrorMessage]) {
    return [FIRAuthErrorUtils invalidCustomTokenErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kCustomTokenMismatch]) {
    return [FIRAuthErrorUtils customTokenMistmatchErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidCredentialErrorMessage]) {
    return [FIRAuthErrorUtils invalidCredentialErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kUserDisabledErrorMessage]) {
    return [FIRAuthErrorUtils userDisabledErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kOperationNotAllowedErrorMessage]) {
    return [FIRAuthErrorUtils operationNotAllowedErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kPasswordLoginDisabledErrorMessage]) {
    return [FIRAuthErrorUtils operationNotAllowedErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kEmailAlreadyInUseErrorMessage]) {
    return [FIRAuthErrorUtils emailAlreadyInUseErrorWithEmail:nil];
  }

  if ([shortErrorMessage isEqualToString:kInvalidEmailErrorMessage]) {
    return [FIRAuthErrorUtils invalidEmailErrorWithMessage:serverDetailErrorMessage];
  }

  // "INVALID_IDENTIFIER" can be returned by createAuthURI RPC. Considering email addresses are
  //  currently the only identifiers, we surface the FIRAuthErrorCodeInvalidEmail error code in this
  //  case.
  if ([shortErrorMessage isEqualToString:kInvalidIdentifierErrorMessage]) {
    return [FIRAuthErrorUtils invalidEmailErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kWrongPasswordErrorMessage]) {
    return [FIRAuthErrorUtils wrongPasswordErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kCredentialTooOldErrorMessage]) {
    return [FIRAuthErrorUtils requiresRecentLoginErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidUserTokenErrorMessage]) {
    return [FIRAuthErrorUtils invalidUserTokenErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kFederatedUserIDAlreadyLinkedMessage]) {
    return [FIRAuthErrorUtils credentialAlreadyInUseErrorWithMessage:serverDetailErrorMessage
                                                          credential:nil];
  }

  if ([shortErrorMessage isEqualToString:kWeakPasswordErrorMessagePrefix]) {
    return [FIRAuthErrorUtils weakPasswordErrorWithServerResponseReason:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kExpiredActionCodeErrorMessage]) {
    return [FIRAuthErrorUtils expiredActionCodeErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidActionCodeErrorMessage]) {
    return [FIRAuthErrorUtils invalidActionCodeErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingEmailErrorMessage]) {
    return [FIRAuthErrorUtils missingEmailErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidSenderEmailErrorMessage]) {
    return [FIRAuthErrorUtils invalidSenderErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidMessagePayloadErrorMessage]) {
    return [FIRAuthErrorUtils invalidMessagePayloadErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidRecipientEmailErrorMessage]) {
    return [FIRAuthErrorUtils invalidRecipientEmailErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingIosBundleIDErrorMessage]) {
    return [FIRAuthErrorUtils missingIosBundleIDErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingAndroidPackageNameErrorMessage]) {
    return [FIRAuthErrorUtils missingAndroidPackageNameErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kUnauthorizedDomainErrorMessage]) {
    return [FIRAuthErrorUtils unauthorizedDomainErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidContinueURIErrorMessage]) {
    return [FIRAuthErrorUtils invalidContinueURIErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingContinueURIErrorMessage]) {
    return [FIRAuthErrorUtils missingContinueURIErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidPhoneNumberErrorMessage]) {
    return [FIRAuthErrorUtils invalidPhoneNumberErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidSessionInfoErrorMessage]) {
    return [FIRAuthErrorUtils invalidVerificationIDErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidVerificationCodeErrorMessage]) {
    return [FIRAuthErrorUtils invalidVerificationCodeErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kSessionExpiredErrorMessage]) {
    return [FIRAuthErrorUtils sessionExpiredErrorWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingAppTokenErrorMessage]) {
    return [FIRAuthErrorUtils missingAppTokenErrorWithUnderlyingError:nil];
  }

  if ([shortErrorMessage isEqualToString:kMissingAppCredentialErrorMessage]) {
    return [FIRAuthErrorUtils missingAppCredentialWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kInvalidAppCredentialErrorMessage]) {
    return [FIRAuthErrorUtils invalidAppCredentialWithMessage:serverDetailErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kQuoutaExceededErrorMessage]) {
    return [FIRAuthErrorUtils quotaExceededErrorWithMessage:serverErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kAppNotVerifiedErrorMessage]) {
    return [FIRAuthErrorUtils appNotVerifiedErrorWithMessage:serverErrorMessage];
  }

  if ([shortErrorMessage isEqualToString:kMissingClientIdentifier]) {
    return [FIRAuthErrorUtils appNotVerifiedErrorWithMessage:@"Missing app verification via"
        " reCAPTCHA or APNS token. Please verify that appVerificationDisabledForTesting is not"
        " enabled when testing with a phone number that is not marked as a test Phone number in the"
        " app console."];
  }

  if ([shortErrorMessage isEqualToString:kCaptchaCheckFailedErrorMessage]) {
    return [FIRAuthErrorUtils captchaCheckFailedErrorWithMessage:serverErrorMessage];
  }

  // In this case we handle an error that might be specified in the underlying errors dictionary,
  // the error message in determined based on the @c reason key in the dictionary.
  if (errorDictionary[kErrorsKey]) {
    // Check for underlying error with reason = keyInvalid;
    id underlyingErrors = errorDictionary[kErrorsKey];
    if ([underlyingErrors isKindOfClass:[NSArray class]]) {
      NSArray *underlyingErrorsArray = (NSArray *)underlyingErrors;
      for (id underlyingError in underlyingErrorsArray) {
        if ([underlyingError isKindOfClass:[NSDictionary class]]) {
          NSDictionary *underlyingErrorDictionary = (NSDictionary *)underlyingError;
          NSString *reason = underlyingErrorDictionary[kReasonKey];
          if ([reason hasPrefix:kInvalidKeyReasonValue]) {
            return [FIRAuthErrorUtils invalidAPIKeyError];
          }
          if ([reason isEqualToString:kAppNotAuthorizedReasonValue]) {
            return [FIRAuthErrorUtils appNotAuthorizedError];
          }
        }
      }
    }
  }
  return nil;
}

@end
