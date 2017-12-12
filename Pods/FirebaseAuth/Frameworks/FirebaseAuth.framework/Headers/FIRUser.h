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

#import "FIRAuth.h"
#import "FIRAuthDataResult.h"
#import "FIRUserInfo.h"

@class FIRPhoneAuthCredential;
@class FIRUserProfileChangeRequest;
@class FIRUserMetadata;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRAuthTokenCallback
    @brief The type of block called when a token is ready for use.
    @see FIRUser.getIDTokenWithCompletion:
    @see FIRUser.getIDTokenForcingRefresh:withCompletion:

    @param token Optionally; an access token if the request was successful.
    @param error Optionally; the error which occurred - or nil if the request was successful.

    @remarks One of: @c token or @c error will always be non-nil.
 */
typedef void (^FIRAuthTokenCallback)(NSString *_Nullable token, NSError *_Nullable error)
    NS_SWIFT_NAME(AuthTokenCallback);

/** @typedef FIRUserProfileChangeCallback
    @brief The type of block called when a user profile change has finished.

    @param error Optionally; the error which occurred - or nil if the request was successful.
 */
typedef void (^FIRUserProfileChangeCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(UserProfileChangeCallback);

/** @typedef FIRSendEmailVerificationCallback
    @brief The type of block called when a request to send an email verification has finished.

    @param error Optionally; the error which occurred - or nil if the request was successful.
 */
typedef void (^FIRSendEmailVerificationCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(SendEmailVerificationCallback);

/** @class FIRUser
    @brief Represents a user.
    @remarks This class is thread-safe.
 */
NS_SWIFT_NAME(User)
@interface FIRUser : NSObject <FIRUserInfo>

/** @property anonymous
    @brief Indicates the user represents an anonymous user.
 */
@property(nonatomic, readonly, getter=isAnonymous) BOOL anonymous;

/** @property emailVerified
    @brief Indicates the email address associated with this user has been verified.
 */
@property(nonatomic, readonly, getter=isEmailVerified) BOOL emailVerified;

/** @property refreshToken
    @brief A refresh token; useful for obtaining new access tokens independently.
    @remarks This property should only be used for advanced scenarios, and is not typically needed.
 */
@property(nonatomic, readonly, nullable) NSString *refreshToken;

/** @property providerData
    @brief Profile data for each identity provider, if any.
    @remarks This data is cached on sign-in and updated when linking or unlinking.
 */
@property(nonatomic, readonly, nonnull) NSArray<id<FIRUserInfo>> *providerData;

/** @property metadata
    @brief Metadata associated with the Firebase user in question.
 */
@property(nonatomic, readonly, nonnull) FIRUserMetadata *metadata;

/** @fn init
    @brief This class should not be instantiated.
    @remarks To retrieve the current user, use @c FIRAuth.currentUser. To sign a user
        in or out, use the methods on @c FIRAuth.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn updateEmail:completion:
    @brief Updates the email address for the user. On success, the cached user profile data is
        updated.
    @remarks May fail if there is already an account with this email address that was created using
        email and password authentication.

    @param email The email address for the user.
    @param completion Optionally; the block invoked when the user profile change has finished.
        Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeInvalidRecipientEmail - Indicates an invalid recipient email was
            sent in the request.
        </li>
        <li>@c FIRAuthErrorCodeInvalidSender - Indicates an invalid sender email is set in
            the console for this action.
        </li>
        <li>@c FIRAuthErrorCodeInvalidMessagePayload - Indicates an invalid email template for
            sending update email.
        </li>
        <li>@c FIRAuthErrorCodeEmailAlreadyInUse - Indicates the email is already in use by another
            account.
        </li>
        <li>@c FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.
        </li>
        <li>@c FIRAuthErrorCodeRequiresRecentLogin - Updating a user’s email is a security
            sensitive operation that requires a recent login from the user. This error indicates
            the user has not signed in recently enough. To resolve, reauthenticate the user by
            invoking reauthenticateWithCredential:completion: on FIRUser.
        </li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)updateEmail:(NSString *)email completion:(nullable FIRUserProfileChangeCallback)completion
    NS_SWIFT_NAME(updateEmail(to:completion:));

/** @fn updatePassword:completion:
    @brief Updates the password for the user. On success, the cached user profile data is updated.

    @param password The new password for the user.
    @param completion Optionally; the block invoked when the user profile change has finished.
        Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeOperationNotAllowed - Indicates the administrator disabled
            sign in with the specified identity provider.
        </li>
        <li>@c FIRAuthErrorCodeRequiresRecentLogin - Updating a user’s password is a security
            sensitive operation that requires a recent login from the user. This error indicates
            the user has not signed in recently enough. To resolve, reauthenticate the user by
            invoking reauthenticateWithCredential:completion: on FIRUser.
        </li>
        <li>@c FIRAuthErrorCodeWeakPassword - Indicates an attempt to set a password that is
            considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
            dictionary object will contain more detailed explanation that can be shown to the user.
        </li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)updatePassword:(NSString *)password
            completion:(nullable FIRUserProfileChangeCallback)completion
    NS_SWIFT_NAME(updatePassword(to:completion:));

#if TARGET_OS_IOS
/** @fn updatePhoneNumberCredential:completion:
    @brief Updates the phone number for the user. On success, the cached user profile data is
        updated.

    @param phoneNumberCredential The new phone number credential corresponding to the phone number
        to be added to the firebaes account, if a phone number is already linked to the account this
        new phone number will replace it.
    @param completion Optionally; the block invoked when the user profile change has finished.
        Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeRequiresRecentLogin - Updating a user’s phone number is a security
            sensitive operation that requires a recent login from the user. This error indicates
            the user has not signed in recently enough. To resolve, reauthenticate the user by
            invoking reauthenticateWithCredential:completion: on FIRUser.
        </li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)updatePhoneNumberCredential:(FIRPhoneAuthCredential *)phoneNumberCredential
                         completion:(nullable FIRUserProfileChangeCallback)completion;
#endif

/** @fn profileChangeRequest
    @brief Creates an object which may be used to change the user's profile data.

    @remarks Set the properties of the returned object, then call
        @c FIRUserProfileChangeRequest.commitChangesWithCallback: to perform the updates atomically.

    @return An object which may be used to change the user's profile data atomically.
 */
- (FIRUserProfileChangeRequest *)profileChangeRequest NS_SWIFT_NAME(createProfileChangeRequest());

/** @fn reloadWithCompletion:
    @brief Reloads the user's profile data from the server.

    @param completion Optionally; the block invoked when the reload has finished. Invoked
        asynchronously on the main thread in the future.

    @remarks May fail with a @c FIRAuthErrorCodeRequiresRecentLogin error code. In this case
        you should call @c FIRUser.reauthenticateWithCredential:completion: before re-invoking
        @c FIRUser.updateEmail:completion:.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)reloadWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn reauthenticateWithCredential:completion:
    @brief Convenience method for @c reauthenticateAndRetrieveDataWithCredential:completion: This
        method doesn't return additional identity provider data.
 */
- (void)reauthenticateWithCredential:(FIRAuthCredential *)credential
                          completion:(nullable FIRUserProfileChangeCallback)completion;

/** @fn reauthenticateWithCredential:completion:
    @brief Renews the user's authentication tokens by validating a fresh set of credentials supplied
        by the user  and returns additional identity provider data.

    @param credential A user-supplied credential, which will be validated by the server. This can be
        a successful third-party identity provider sign-in, or an email address and password.
    @param completion Optionally; the block invoked when the re-authentication operation has
        finished. Invoked asynchronously on the main thread in the future.

    @remarks If the user associated with the supplied credential is different from the current user,
        or if the validation of the supplied credentials fails; an error is returned and the current
        user remains signed in.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeInvalidCredential - Indicates the supplied credential is invalid.
            This could happen if it has expired or it is malformed.
        </li>
        <li>@c FIRAuthErrorCodeOperationNotAllowed - Indicates that accounts with the
            identity provider represented by the credential are not enabled. Enable them in the
            Auth section of the Firebase console.
        </li>
        <li>@c FIRAuthErrorCodeEmailAlreadyInUse -  Indicates the email asserted by the credential
            (e.g. the email in a Facebook access token) is already in use by an existing account,
            that cannot be authenticated with this method. Call fetchProvidersForEmail for
            this user’s email and then prompt them to sign in with any of the sign-in providers
            returned. This error will only be thrown if the "One account per email address"
            setting is enabled in the Firebase console, under Auth settings. Please note that the
            error code raised in this specific situation may not be the same on Web and Android.
        </li>
        <li>@c FIRAuthErrorCodeUserDisabled - Indicates the user's account is disabled.
        </li>
        <li>@c FIRAuthErrorCodeWrongPassword - Indicates the user attempted reauthentication with
            an incorrect password, if credential is of the type EmailPasswordAuthCredential.
        </li>
        <li>@c FIRAuthErrorCodeUserMismatch -  Indicates that an attempt was made to
            reauthenticate with a user which is not the current user.
        </li>
        <li>@c FIRAuthErrorCodeInvalidEmail - Indicates the email address is malformed.</li>
    </ul>
    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)reauthenticateAndRetrieveDataWithCredential:(FIRAuthCredential *) credential
                                         completion:(nullable FIRAuthDataResultCallback) completion;

/** @fn getIDTokenWithCompletion:
    @brief Retrieves the Firebase authentication token, possibly refreshing it if it has expired.

    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getIDTokenWithCompletion:(nullable FIRAuthTokenCallback)completion
    NS_SWIFT_NAME(getIDToken(completion:));

/** @fn getTokenWithCompletion:
    @brief Please use @c getIDTokenWithCompletion: instead.

    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getTokenWithCompletion:(nullable FIRAuthTokenCallback)completion
    NS_SWIFT_NAME(getToken(completion:)) __attribute__((deprecated));

/** @fn getIDTokenForcingRefresh:completion:
    @brief Retrieves the Firebase authentication token, possibly refreshing it if it has expired.

    @param forceRefresh Forces a token refresh. Useful if the token becomes invalid for some reason
        other than an expiration.
    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.

    @remarks The authentication token will be refreshed (by making a network request) if it has
        expired, or if @c forceRefresh is YES.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getIDTokenForcingRefresh:(BOOL)forceRefresh
                      completion:(nullable FIRAuthTokenCallback)completion;

/** @fn getTokenForcingRefresh:completion:
    @brief Please use getIDTokenForcingRefresh:completion instead.

    @param forceRefresh Forces a token refresh. Useful if the token becomes invalid for some reason
        other than an expiration.
    @param completion Optionally; the block invoked when the token is available. Invoked
        asynchronously on the main thread in the future.

    @remarks The authentication token will be refreshed (by making a network request) if it has
        expired, or if @c forceRefresh is YES.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */
- (void)getTokenForcingRefresh:(BOOL)forceRefresh
                    completion:(nullable FIRAuthTokenCallback)completion
                        __attribute__((deprecated));

/** @fn linkWithCredential:completion:
    @brief Convenience method for @c linkAndRetrieveDataWithCredential:completion: This method
        doesn't return additional identity provider data.
 */
- (void)linkWithCredential:(FIRAuthCredential *)credential
                completion:(nullable FIRAuthResultCallback)completion;

/** @fn linkAndRetrieveDataWithCredential:completion:
    @brief Associates a user account from a third-party identity provider with this user and
    returns additional identity provider data.

    @param credential The credential for the identity provider.
    @param completion Optionally; the block invoked when the unlinking is complete, or fails.
        Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeProviderAlreadyLinked - Indicates an attempt to link a provider of a
            type already linked to this account.
        </li>
        <li>@c FIRAuthErrorCodeCredentialAlreadyInUse - Indicates an attempt to link with a
            credential
            that has already been linked with a different Firebase account.
        </li>
        <li>@c FIRAuthErrorCodeOperationNotAllowed - Indicates that accounts with the identity
            provider represented by the credential are not enabled. Enable them in the Auth section
            of the Firebase console.
        </li>
    </ul>

    @remarks This method may also return error codes associated with updateEmail:completion: and
            updatePassword:completion: on FIRUser.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)linkAndRetrieveDataWithCredential:(FIRAuthCredential *) credential
                               completion:(nullable FIRAuthDataResultCallback) completion;

/** @fn unlinkFromProvider:completion:
    @brief Disassociates a user account from a third-party identity provider with this user.

    @param provider The provider ID of the provider to unlink.
    @param completion Optionally; the block invoked when the unlinking is complete, or fails.
        Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeNoSuchProvider - Indicates an attempt to unlink a provider
            that is not linked to the account.
        </li>
        <li>@c FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive
            operation that requires a recent login from the user. This error indicates the user
            has not signed in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        </li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)unlinkFromProvider:(NSString *)provider
                completion:(nullable FIRAuthResultCallback)completion;

/** @fn sendEmailVerificationWithCompletion:
    @brief Initiates email verification for the user.

    @param completion Optionally; the block invoked when the request to send an email verification
        is complete, or fails. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeInvalidRecipientEmail - Indicates an invalid recipient email was
            sent in the request.
        </li>
        <li>@c FIRAuthErrorCodeInvalidSender - Indicates an invalid sender email is set in
            the console for this action.
        </li>
        <li>@c FIRAuthErrorCodeInvalidMessagePayload - Indicates an invalid email template for
            sending update email.
        </li>
        <li>@c FIRAuthErrorCodeUserNotFound - Indicates the user account was not found.</li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.
 */
- (void)sendEmailVerificationWithCompletion:(nullable FIRSendEmailVerificationCallback)completion;

/** @fn sendEmailVerificationWithActionCodeSettings:completion:
    @brief Initiates email verification for the user.

    @param actionCodeSettings An @c FIRActionCodeSettings object containing settings related to
        handling action codes.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeInvalidRecipientEmail - Indicates an invalid recipient email was
            sent in the request.
        </li>
        <li>@c FIRAuthErrorCodeInvalidSender - Indicates an invalid sender email is set in
            the console for this action.
        </li>
        <li>@c FIRAuthErrorCodeInvalidMessagePayload - Indicates an invalid email template for
            sending update email.
        </li>
        <li>@c FIRAuthErrorCodeUserNotFound - Indicates the user account was not found.</li>
        <li>@c FIRAuthErrorCodeMissingIosBundleID - Indicates that the iOS bundle ID is missing when
            a iOS App Store ID is provided.
        </li>
        <li>@c FIRAuthErrorCodeMissingAndroidPackageName - Indicates that the android package name
            is missing when the @c androidInstallApp flag is set to true.
        </li>
        <li>@c FIRAuthErrorCodeUnauthorizedDomain - Indicates that the domain specified in the
            continue URL is not whitelisted in the Firebase console.
        </li>
        <li>@c FIRAuthErrorCodeInvalidContinueURI - Indicates that the domain specified in the
            continue URI is not valid.
        </li>
    </ul>
 */
- (void)sendEmailVerificationWithActionCodeSettings:(FIRActionCodeSettings *)actionCodeSettings
                                         completion:(nullable FIRSendEmailVerificationCallback)
                                                    completion;

/** @fn deleteWithCompletion:
    @brief Deletes the user account (also signs out the user, if this was the current user).

    @param completion Optionally; the block invoked when the request to delete the account is
        complete, or fails. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:
    <ul>
        <li>@c FIRAuthErrorCodeRequiresRecentLogin - Updating email is a security sensitive
            operation that requires a recent login from the user. This error indicates the user
            has not signed in recently enough. To resolve, reauthenticate the user by invoking
            reauthenticateWithCredential:completion: on FIRUser.
        </li>
    </ul>

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all FIRUser methods.

 */
- (void)deleteWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

@end

/** @class FIRUserProfileChangeRequest
    @brief Represents an object capable of updating a user's profile data.
    @remarks Properties are marked as being part of a profile update when they are set. Setting a
        property value to nil is not the same as leaving the property unassigned.
 */
NS_SWIFT_NAME(UserProfileChangeRequest)
@interface FIRUserProfileChangeRequest : NSObject

/** @fn init
    @brief Please use @c FIRUser.profileChangeRequest
 */
- (instancetype)init NS_UNAVAILABLE;

/** @property displayName
    @brief The user's display name.
    @remarks It is an error to set this property after calling
        @c FIRUserProfileChangeRequest.commitChangesWithCallback:
 */
@property(nonatomic, copy, nullable) NSString *displayName;

/** @property photoURL
    @brief The user's photo URL.
    @remarks It is an error to set this property after calling
        @c FIRUserProfileChangeRequest.commitChangesWithCallback:
 */
@property(nonatomic, copy, nullable) NSURL *photoURL;

/** @fn commitChangesWithCompletion:
    @brief Commits any pending changes.
    @remarks This method should only be called once. Once called, property values should not be
        changed.

    @param completion Optionally; the block invoked when the user profile change has been applied.
        Invoked asynchronously on the main thread in the future.
 */
- (void)commitChangesWithCompletion:(nullable FIRUserProfileChangeCallback)completion;

@end

NS_ASSUME_NONNULL_END
