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

#import "FIRAuthSwiftNameSupport.h"

/** @class FIRAuthErrors
    @remarks Error Codes common to all API Methods:
    <ul>
        <li>@c FIRAuthErrorCodeNetworkError</li>
        <li>@c FIRAuthErrorCodeUserNotFound</li>
        <li>@c FIRAuthErrorCodeUserTokenExpired</li>
        <li>@c FIRAuthErrorCodeTooManyRequests</li>
        <li>@c FIRAuthErrorCodeInvalidAPIKey</li>
        <li>@c FIRAuthErrorCodeAppNotAuthorized</li>
        <li>@c FIRAuthErrorCodeKeychainError</li>
        <li>@c FIRAuthErrorCodeInternalError</li>
    </ul>
    @remarks Common error codes for @c FIRUser operations:
    <ul>
        <li>@c FIRAuthErrorCodeInvalidUserToken</li>
        <li>@c FIRAuthErrorCodeUserDisabled</li>
    </ul>
 */
FIR_SWIFT_NAME(AuthErrors)
@interface FIRAuthErrors

/**
    @brief The Firebase Auth error domain.
 */
extern NSString *const FIRAuthErrorDomain FIR_SWIFT_NAME(AuthErrorDomain);

/**
    @brief The key used to read the updated credential from the userinfo dictionary of the NSError
        object returned in the case that the credential being linked in already in use.
 */
extern NSString *const FIRAuthUpdatedCredentialKey FIR_SWIFT_NAME(AuthUpdatedCredentialKey);

/**
    @brief The name of the key for the "error_name" string in the NSError userinfo dictionary.
 */
extern NSString *const FIRAuthErrorNameKey FIR_SWIFT_NAME(AuthErrorNameKey);

/** @var FIRAuthErrorUserInfoEmailKey
    @brief Errors with the code @c FIRAuthErrorCodeEmailAlreadyInUse may contains an
        @c NSError.userInfo dictinary which contains this key. The value associated with this key is
        an NSString of the email address that already exists.
 */
extern NSString *const FIRAuthErrorUserInfoEmailKey FIR_SWIFT_NAME(AuthErrorUserInfoEmailKey);

/**
    @brief Error codes used by Firebase Auth.
 */
typedef NS_ENUM(NSInteger, FIRAuthErrorCode) {
    /** Indicates a validation error with the custom token.
     */
    FIRAuthErrorCodeInvalidCustomToken = 17000,

    /** Indicates the service account and the API key belong to different projects.
     */
    FIRAuthErrorCodeCustomTokenMismatch = 17002,

    /** Indicates the IDP token or requestUri is invalid.
     */
    FIRAuthErrorCodeInvalidCredential = 17004,

    /** Indicates the user's account is disabled on the server.
     */
    FIRAuthErrorCodeUserDisabled = 17005,

    /** Indicates the administrator disabled sign in with the specified identity provider.
     */
    FIRAuthErrorCodeOperationNotAllowed = 17006,

    /** Indicates the email used to attempt a sign up is already in use.
     */
    FIRAuthErrorCodeEmailAlreadyInUse = 17007,

    /** Indicates the email is invalid.
     */
    FIRAuthErrorCodeInvalidEmail = 17008,

    /** Indicates the user attempted sign in with a wrong password.
     */
    FIRAuthErrorCodeWrongPassword = 17009,

    /** Indicates that too many requests were made to a server method.
     */
    FIRAuthErrorCodeTooManyRequests = 17010,

    /** Indicates the user account was not found.
     */
    FIRAuthErrorCodeUserNotFound = 17011,

    /** Indicates account linking is required.
     */
    FIRAuthErrorCodeAccountExistsWithDifferentCredential = 17012,

    /** Indicates the user has attemped to change email or password more than 5 minutes after
        signing in.
     */
    FIRAuthErrorCodeRequiresRecentLogin = 17014,

    /** Indicates an attempt to link a provider to which the account is already linked.
     */
    FIRAuthErrorCodeProviderAlreadyLinked = 17015,

    /** Indicates an attempt to unlink a provider that is not linked.
     */
    FIRAuthErrorCodeNoSuchProvider = 17016,

    /** Indicates user's saved auth credential is invalid, the user needs to sign in again.
     */
    FIRAuthErrorCodeInvalidUserToken = 17017,

    /** Indicates a network error occurred (such as a timeout, interrupted connection, or
        unreachable host). These types of errors are often recoverable with a retry. The
        @c NSUnderlyingError field in the @c NSError.userInfo dictionary will contain the error
        encountered.
     */
    FIRAuthErrorCodeNetworkError = 17020,

    /** Indicates the saved token has expired, for example, the user may have changed account
        password on another device. The user needs to sign in again on the device that made this
        request.
     */
    FIRAuthErrorCodeUserTokenExpired = 17021,

    /** Indicates an invalid API key was supplied in the request.
     */
    FIRAuthErrorCodeInvalidAPIKey = 17023,

    /** Indicates that an attempt was made to reauthenticate with a user which is not the current
        user.
     */
    FIRAuthErrorCodeUserMismatch = 17024,

    /** Indicates an attempt to link with a credential that has already been linked with a
        different Firebase account
     */
    FIRAuthErrorCodeCredentialAlreadyInUse = 17025,

    /** Indicates an attempt to set a password that is considered too weak.
     */
    FIRAuthErrorCodeWeakPassword = 17026,

    /** Indicates the App is not authorized to use Firebase Authentication with the
        provided API Key.
     */
    FIRAuthErrorCodeAppNotAuthorized = 17028,

    /** Indicates the OOB code is expired.
     */
    FIRAuthErrorCodeExpiredActionCode = 17029,

    /** Indicates the OOB code is invalid.
     */
    FIRAuthErrorCodeInvalidActionCode = 17030,

    /** Indicates that there are invalid parameters in the payload during a "send password reset
     *  email" attempt.
     */
    FIRAuthErrorCodeInvalidMessagePayload = 17031,

    /** Indicates that the sender email is invalid during a "send password reset email" attempt.
     */
    FIRAuthErrorCodeInvalidSender = 17032,

    /** Indicates that the recipient email is invalid.
     */
    FIRAuthErrorCodeInvalidRecipientEmail = 17033,

    /** Indicates that an email address was expected but one was not provided.
     */
    FIRAuthErrorCodeMissingEmail = 17034,

    // The enum values 17035 is reserved and should NOT be used for new error codes.

    /** Indicates that the iOS bundle ID is missing when a iOS App Store ID is provided.
     */
    FIRAuthErrorCodeMissingIosBundleID = 17036,

    /** Indicates that the android package name is missing when the @c androidInstallApp flag is set
        to true.
     */
    FIRAuthErrorCodeMissingAndroidPackageName = 17037,

    /** Indicates that the domain specified in the continue URL is not whitelisted in the Firebase
        console.
     */
    FIRAuthErrorCodeUnauthorizedDomain = 17038,

    /** Indicates that the domain specified in the continue URI is not valid.
     */
    FIRAuthErrorCodeInvalidContinueURI = 17039,

    /** Indicates that a continue URI was not provided in a request to the backend which requires
        one.
     */
    FIRAuthErrorCodeMissingContinueURI = 17040,

    /** Indicates that a phone number was not provided in a call to
        @c verifyPhoneNumber:completion:.
     */
    FIRAuthErrorCodeMissingPhoneNumber = 17041,

    /** Indicates that an invalid phone number was provided in a call to
        @c verifyPhoneNumber:completion:.
     */
    FIRAuthErrorCodeInvalidPhoneNumber = 17042,

    /** Indicates that the phone auth credential was created with an empty verification code.
     */
    FIRAuthErrorCodeMissingVerificationCode = 17043,

    /** Indicates that an invalid verification code was used in the verifyPhoneNumber request.
     */
    FIRAuthErrorCodeInvalidVerificationCode = 17044,

    /** Indicates that the phone auth credential was created with an empty verification ID.
     */
    FIRAuthErrorCodeMissingVerificationID = 17045,

    /** Indicates that an invalid verification ID was used in the verifyPhoneNumber request.
     */
    FIRAuthErrorCodeInvalidVerificationID = 17046,

    /** Indicates that the APNS device token is missing in the verifyClient request.
     */
    FIRAuthErrorCodeMissingAppCredential = 17047,

    /** Indicates that an invalid APNS device token was used in the verifyClient request.
     */
    FIRAuthErrorCodeInvalidAppCredential = 17048,

    // The enum values between 17048 and 17051 are reserved and should NOT be used for new error
    // codes.

    /** Indicates that the SMS code has expired.
     */
    FIRAuthErrorCodeSessionExpired = 17051,

    /** Indicates that the quota of SMS messages for a given project has been exceeded.
     */
    FIRAuthErrorCodeQuotaExceeded = 17052,

    /** Indicates that the APNs device token could not be obtained. The app may not have set up
        remote notification correctly, or may fail to forward the APNs device token to FIRAuth
        if app delegate swizzling is disabled.
     */
    FIRAuthErrorCodeMissingAppToken = 17053,

    /** Indicates that the app fails to forward remote notification to FIRAuth.
     */
    FIRAuthErrorCodeNotificationNotForwarded = 17054,

    /** Indicates that the app could not be verified by Firebase during phone number authentication.
     */
    FIRAuthErrorCodeAppNotVerified = 17055,

    /** Indicates that the reCAPTCHA token is not valid.
     */
    FIRAuthErrorCodeCaptchaCheckFailed = 17056,

    /** Indicates that an attempt was made to present a new web context while one was already being
        presented.
     */
    FIRAuthErrorCodeWebContextAlreadyPresented = 17057,

    /** Indicates that the URL presentation was cancelled prematurely by the user.
     */
    FIRAuthErrorCodeWebContextCancelled = 17058,

    /** Indicates a general failure during the app verification flow.
     */
    FIRAuthErrorCodeAppVerificationUserInteractionFailure = 17059,

    /** Indicates that the clientID used to invoke a web flow is invalid.
     */
    FIRAuthErrorCodeInvalidClientID = 17060,

    /** Indicates an error occurred while attempting to access the keychain.
     */
    FIRAuthErrorCodeKeychainError = 17995,

    /** Indicates an internal error occurred.
     */
    FIRAuthErrorCodeInternalError = 17999,
} FIR_SWIFT_NAME(AuthErrorCode);

@end
