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

#import <AvailabilityMacros.h>
#import <Foundation/Foundation.h>

#import "FIRAuthErrors.h"

#if TARGET_OS_IOS
#import "FIRAuthAPNSTokenType.h"
#endif

@class FIRActionCodeSettings;
@class FIRApp;
@class FIRAuth;
@class FIRAuthCredential;
@class FIRAuthDataResult;
@class FIRAuthSettings;
@class FIRUser;
@protocol FIRAuthStateListener;

NS_ASSUME_NONNULL_BEGIN

/** @typedef FIRUserUpdateCallback
    @brief The type of block invoked when a request to update the current user is completed.
 */
typedef void (^FIRUserUpdateCallback)(NSError *_Nullable error) NS_SWIFT_NAME(UserUpdateCallback);

/** @typedef FIRAuthStateDidChangeListenerHandle
    @brief The type of handle returned by `FIRAuth.addAuthStateDidChangeListener:`.
 */
typedef id<NSObject> FIRAuthStateDidChangeListenerHandle
    NS_SWIFT_NAME(AuthStateDidChangeListenerHandle);

/** @typedef FIRAuthStateDidChangeListenerBlock
    @brief The type of block which can be registered as a listener for auth state did change events.

    @param auth The FIRAuth object on which state changes occurred.
    @param user Optionally; the current signed in user, if any.
 */
typedef void(^FIRAuthStateDidChangeListenerBlock)(FIRAuth *auth, FIRUser *_Nullable user)
    NS_SWIFT_NAME(AuthStateDidChangeListenerBlock);

/** @typedef FIRIDTokenDidChangeListenerHandle
    @brief The type of handle returned by `FIRAuth.addIDTokenDidChangeListener:`.
 */
typedef id<NSObject> FIRIDTokenDidChangeListenerHandle
    NS_SWIFT_NAME(IDTokenDidChangeListenerHandle);

/** @typedef FIRIDTokenDidChangeListenerBlock
    @brief The type of block which can be registered as a listener for ID token did change events.

    @param auth The FIRAuth object on which ID token changes occurred.
    @param user Optionally; the current signed in user, if any.
 */
typedef void(^FIRIDTokenDidChangeListenerBlock)(FIRAuth *auth, FIRUser *_Nullable user)
    NS_SWIFT_NAME(IDTokenDidChangeListenerBlock);

/** @typedef FIRAuthDataResultCallback
    @brief The type of block invoked when sign-in related events complete.

    @param authResult Optionally; Result of sign-in request containing both the user and
       the additional user info associated with the user.
    @param error Optionally; the error which occurred - or nil if the request was successful.
 */
typedef void (^FIRAuthDataResultCallback)(FIRAuthDataResult *_Nullable authResult,
                                          NSError *_Nullable error)
    NS_SWIFT_NAME(AuthDataResultCallback);

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
/**
    @brief The name of the `NSNotificationCenter` notification which is posted when the auth state
        changes (for example, a new token has been produced, a user signs in or signs out). The
        object parameter of the notification is the sender `FIRAuth` instance.
 */
extern const NSNotificationName FIRAuthStateDidChangeNotification
    NS_SWIFT_NAME(AuthStateDidChange);
#else
/**
    @brief The name of the `NSNotificationCenter` notification which is posted when the auth state
        changes (for example, a new token has been produced, a user signs in or signs out). The
        object parameter of the notification is the sender `FIRAuth` instance.
 */
extern NSString *const FIRAuthStateDidChangeNotification
    NS_SWIFT_NAME(AuthStateDidChangeNotification);
#endif  // defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

/** @typedef FIRAuthResultCallback
    @brief The type of block invoked when sign-in related events complete.

    @param user Optionally; the signed in user, if any.
    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRAuthResultCallback)(FIRUser *_Nullable user, NSError *_Nullable error)
    NS_SWIFT_NAME(AuthResultCallback);

/** @typedef FIRProviderQueryCallback
    @brief The type of block invoked when a list of identity providers for a given email address is
        requested.

    @param providers Optionally; a list of provider identifiers, if any.
        @see FIRGoogleAuthProviderID etc.
    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRProviderQueryCallback)(NSArray<NSString *> *_Nullable providers,
                                         NSError *_Nullable error)
    NS_SWIFT_NAME(ProviderQueryCallback);

/** @typedef FIRSignInMethodQueryCallback
    @brief The type of block invoked when a list of sign-in methods for a given email address is
        requested.
 */
typedef void (^FIRSignInMethodQueryCallback)(NSArray<NSString *> *_Nullable,
                                             NSError *_Nullable)
    NS_SWIFT_NAME(SignInMethodQueryCallback);

/** @typedef FIRSendPasswordResetCallback
    @brief The type of block invoked when sending a password reset email.

    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRSendPasswordResetCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(SendPasswordResetCallback);

/** @typedef FIRSendSignInLinkToEmailCallback
    @brief The type of block invoked when sending an email sign-in link email.
 */
typedef void (^FIRSendSignInLinkToEmailCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(SendSignInLinkToEmailCallback);

/** @typedef FIRConfirmPasswordResetCallback
    @brief The type of block invoked when performing a password reset.

    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRConfirmPasswordResetCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(ConfirmPasswordResetCallback);

/** @typedef FIRVerifyPasswordResetCodeCallback
    @brief The type of block invoked when verifying that an out of band code should be used to
        perform password reset.

    @param email Optionally; the email address of the user for which the out of band code applies.
    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRVerifyPasswordResetCodeCallback)(NSString *_Nullable email,
                                                   NSError *_Nullable error)
    NS_SWIFT_NAME(VerifyPasswordResetCodeCallback);

/** @typedef FIRApplyActionCodeCallback
    @brief The type of block invoked when applying an action code.

    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRApplyActionCodeCallback)(NSError *_Nullable error)
    NS_SWIFT_NAME(ApplyActionCodeCallback);

/**
    @brief Keys used to retrieve operation data from a `FIRActionCodeInfo` object by the
        `dataForKey` method.
  */
typedef NS_ENUM(NSInteger, FIRActionDataKey) {
  /**
   * The email address to which the code was sent.
   * For FIRActionCodeOperationRecoverEmail, the new email address for the account.
   */
  FIRActionCodeEmailKey = 0,

  /** For FIRActionCodeOperationRecoverEmail, the current email address for the account. */
  FIRActionCodeFromEmailKey = 1
} NS_SWIFT_NAME(ActionDataKey);

/** @class FIRActionCodeInfo
    @brief Manages information regarding action codes.
 */
NS_SWIFT_NAME(ActionCodeInfo)
@interface FIRActionCodeInfo : NSObject

/**
    @brief Operations which can be performed with action codes.
  */
typedef NS_ENUM(NSInteger, FIRActionCodeOperation) {
    /** Action code for unknown operation. */
    FIRActionCodeOperationUnknown = 0,

    /** Action code for password reset operation. */
    FIRActionCodeOperationPasswordReset = 1,

    /** Action code for verify email operation. */
    FIRActionCodeOperationVerifyEmail = 2,

    /** Action code for recover email operation. */
    FIRActionCodeOperationRecoverEmail = 3,

    /** Action code for email link operation. */
    FIRActionCodeOperationEmailLink = 4,


} NS_SWIFT_NAME(ActionCodeOperation);

/**
    @brief The operation being performed.
 */
@property(nonatomic, readonly) FIRActionCodeOperation operation;

/** @fn dataForKey:
    @brief The operation being performed.

    @param key The FIRActionDataKey value used to retrieve the operation data.

    @return The operation data pertaining to the provided action code key.
 */
- (NSString *)dataForKey:(FIRActionDataKey)key;

/** @fn init
    @brief please use initWithOperation: instead.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

/** @typedef FIRCheckActionCodeCallBack
    @brief The type of block invoked when performing a check action code operation.

    @param info Metadata corresponding to the action code.
    @param error Optionally; if an error occurs, this is the NSError object that describes the
        problem. Set to nil otherwise.
 */
typedef void (^FIRCheckActionCodeCallBack)(FIRActionCodeInfo *_Nullable info,
                                           NSError *_Nullable error)
    NS_SWIFT_NAME(CheckActionCodeCallback);

/** @class FIRAuth
    @brief Manages authentication for Firebase apps.
    @remarks This class is thread-safe.
 */
NS_SWIFT_NAME(Auth)
@interface FIRAuth : NSObject

/** @fn auth
    @brief Gets the auth object for the default Firebase app.
    @remarks The default Firebase app must have already been configured or an exception will be
        raised.
 */
+ (FIRAuth *)auth NS_SWIFT_NAME(auth());

/** @fn authWithApp:
    @brief Gets the auth object for a `FIRApp`.

    @param app The FIRApp for which to retrieve the associated FIRAuth instance.
    @return The FIRAuth instance associated with the given FIRApp.
 */
+ (FIRAuth *)authWithApp:(FIRApp *)app NS_SWIFT_NAME(auth(app:));

/** @property app
    @brief Gets the `FIRApp` object that this auth object is connected to.
 */
@property(nonatomic, weak, readonly, nullable) FIRApp *app;

/** @property currentUser
    @brief Synchronously gets the cached current user, or null if there is none.
 */
@property(nonatomic, strong, readonly, nullable) FIRUser *currentUser;

/** @property languageCode
    @brief The current user language code. This property can be set to the app's current language by
        calling `useAppLanguage`.

    @remarks The string used to set this property must be a language code that follows BCP 47.
 */
@property (nonatomic, copy, nullable) NSString *languageCode;

/** @property settings
    @brief Contains settings related to the auth object.
 */
@property (nonatomic, copy, nullable) FIRAuthSettings *settings;

#if TARGET_OS_IOS
/** @property APNSToken
    @brief The APNs token used for phone number authentication. The type of the token (production
        or sandbox) will be attempted to be automatcially detected.
    @remarks If swizzling is disabled, the APNs Token must be set for phone number auth to work,
        by either setting this property or by calling `setAPNSToken:type:`
 */
@property(nonatomic, strong, nullable) NSData *APNSToken;
#endif

/** @fn init
    @brief Please access auth instances using `FIRAuth.auth` and `FIRAuth.authForApp:`.
 */
- (instancetype)init NS_UNAVAILABLE;

/** @fn updateCurrentUser:completion:
    @brief Sets the currentUser on the calling Auth instance to the provided user object.
    @param  user The user object to be set as the current user of the calling Auth instance.
    @param completion Optionally; a block invoked after the user of the calling Auth instance has
        been updated or an error was encountered.
 */
- (void)updateCurrentUser:(FIRUser *)user completion:(nullable FIRUserUpdateCallback)completion;

/** @fn fetchProvidersForEmail:completion:
    @brief Fetches the list of IdPs that can be used for signing in with the provided email address.
        Useful for an "identifier-first" sign-in flow.

    @param email The email address for which to obtain a list of identity providers.
    @param completion Optionally; a block which is invoked when the list of providers for the
        specified email address is ready or an error was encountered. Invoked asynchronously on the
        main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.

    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)fetchProvidersForEmail:(NSString *)email
                    completion:(nullable FIRProviderQueryCallback)completion;

/** @fn fetchSignInMethodsForEmail:completion:
    @brief Fetches the list of all sign-in methods previously used for the provided email address.

    @param email The email address for which to obtain a list of sign-in methods.
    @param completion Optionally; a block which is invoked when the list of sign in methods for the
        specified email address is ready or an error was encountered. Invoked asynchronously on the
        main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.

    @remarks See @c FIRAuthErrors for a list of error codes that are common to all API methods.
 */

- (void)fetchSignInMethodsForEmail:(NSString *)email
                        completion:(nullable FIRSignInMethodQueryCallback)completion;

/** @fn signInWithEmail:password:completion:
    @brief Signs in using an email address and password.

    @param email The user's email address.
    @param password The user's password.
    @param completion Optionally; a block which is invoked when the sign in flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that email and password
            accounts are not enabled. Enable them in the Auth section of the
            Firebase console.
        + `FIRAuthErrorCodeUserDisabled` - Indicates the user's account is disabled.
        + `FIRAuthErrorCodeWrongPassword` - Indicates the user attempted
            sign in with an incorrect password.
        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.


    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
             completion:(nullable FIRAuthDataResultCallback)completion;

/** @fn signInWithEmail:link:completion:
    @brief Signs in using an email address and email sign-in link.

    @param email The user's email address.
    @param link The email sign-in link.
    @param completion Optionally; a block which is invoked when the sign in flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that email and email sign-in link
            accounts are not enabled. Enable them in the Auth section of the
            Firebase console.
        + `FIRAuthErrorCodeUserDisabled` - Indicates the user's account is disabled.
        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is invalid.


    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */

- (void)signInWithEmail:(NSString *)email
                   link:(NSString *)link
             completion:(nullable FIRAuthDataResultCallback)completion;

/** @fn signInAndRetrieveDataWithEmail:password:completion:
    @brief Please use `signInWithEmail:password:completion:` for Objective-C or
        `signIn(withEmail:password:completion:)` for Swift instead.

    @param email The user's email address.
    @param password The user's password.
    @param completion Optionally; a block which is invoked when the sign in flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.
 */
- (void)signInAndRetrieveDataWithEmail:(NSString *)email
                              password:(NSString *)password
                            completion:(nullable FIRAuthDataResultCallback)completion
                                DEPRECATED_MSG_ATTRIBUTE(
                                      "Please use signInWithEmail:password:completion: for"
                                      " Objective-C or signIn(withEmail:password:completion:) for"
                                      " Swift instead.");

/** @fn signInWithCredential:completion:
    @brief Please use `signInAndRetrieveDataWithCredential:completion:` for Objective-C or
        `signInAndRetrieveData(with:completion:)` for swift instead

    @param credential The credential supplied by the IdP.
    @param completion Optionally; a block which is invoked when the sign in flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidCredential` - Indicates the supplied credential is invalid.
            This could happen if it has expired or it is malformed.
        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that accounts
            with the identity provider represented by the credential are not enabled.
            Enable them in the Auth section of the Firebase console.
        + `FIRAuthErrorCodeAccountExistsWithDifferentCredential` - Indicates the email asserted
            by the credential (e.g. the email in a Facebook access token) is already in use by an
            existing account, that cannot be authenticated with this sign-in method. Call
            fetchProvidersForEmail for this user’s email and then prompt them to sign in with any of
            the sign-in providers returned. This error will only be thrown if the "One account per
            email address" setting is enabled in the Firebase console, under Auth settings.
        + `FIRAuthErrorCodeUserDisabled` - Indicates the user's account is disabled.
        + `FIRAuthErrorCodeWrongPassword` - Indicates the user attempted sign in with an
            incorrect password, if credential is of the type EmailPasswordAuthCredential.
        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.
        + `FIRAuthErrorCodeMissingVerificationID` - Indicates that the phone auth credential was
            created with an empty verification ID.
        + `FIRAuthErrorCodeMissingVerificationCode` - Indicates that the phone auth credential
            was created with an empty verification code.
        + `FIRAuthErrorCodeInvalidVerificationCode` - Indicates that the phone auth credential
            was created with an invalid verification Code.
        + `FIRAuthErrorCodeInvalidVerificationID` - Indicates that the phone auth credential was
            created with an invalid verification ID.
        + `FIRAuthErrorCodeSessionExpired` - Indicates that the SMS code has expired.



    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods
 */
- (void)signInWithCredential:(FIRAuthCredential *)credential
                  completion:(nullable FIRAuthResultCallback)completion DEPRECATED_MSG_ATTRIBUTE(
                                      "Please use signInAndRetrieveDataWithCredential:completion:"
                                      " for Objective-C or signInAndRetrieveData(with:completion:)"
                                      " for Swift instead.");

/** @fn signInAndRetrieveDataWithCredential:completion:
    @brief Asynchronously signs in to Firebase with the given 3rd-party credentials (e.g. a Facebook
        login Access Token, a Google ID Token/Access Token pair, etc.) and returns additional
        identity provider data.

    @param credential The credential supplied by the IdP.
    @param completion Optionally; a block which is invoked when the sign in flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidCredential` - Indicates the supplied credential is invalid.
            This could happen if it has expired or it is malformed.
        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that accounts
            with the identity provider represented by the credential are not enabled.
            Enable them in the Auth section of the Firebase console.
        + `FIRAuthErrorCodeAccountExistsWithDifferentCredential` - Indicates the email asserted
            by the credential (e.g. the email in a Facebook access token) is already in use by an
            existing account, that cannot be authenticated with this sign-in method. Call
            fetchProvidersForEmail for this user’s email and then prompt them to sign in with any of
            the sign-in providers returned. This error will only be thrown if the "One account per
            email address" setting is enabled in the Firebase console, under Auth settings.
        + `FIRAuthErrorCodeUserDisabled` - Indicates the user's account is disabled.
        + `FIRAuthErrorCodeWrongPassword` - Indicates the user attempted sign in with an
            incorrect password, if credential is of the type EmailPasswordAuthCredential.
        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.
        + `FIRAuthErrorCodeMissingVerificationID` - Indicates that the phone auth credential was
            created with an empty verification ID.
        + `FIRAuthErrorCodeMissingVerificationCode` - Indicates that the phone auth credential
            was created with an empty verification code.
        + `FIRAuthErrorCodeInvalidVerificationCode` - Indicates that the phone auth credential
            was created with an invalid verification Code.
        + `FIRAuthErrorCodeInvalidVerificationID` - Indicates that the phone auth credential was
            created with an invalid verification ID.
        + `FIRAuthErrorCodeSessionExpired` - Indicates that the SMS code has expired.



    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods
 */
- (void)signInAndRetrieveDataWithCredential:(FIRAuthCredential *)credential
                                 completion:(nullable FIRAuthDataResultCallback)completion;

/** @fn signInAnonymouslyWithCompletion:
    @brief Asynchronously creates and becomes an anonymous user.
    @param completion Optionally; a block which is invoked when the sign in finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks If there is already an anonymous user signed in, that user will be returned instead.
        If there is any other existing user signed in, that user will be signed out.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that anonymous accounts are
            not enabled. Enable them in the Auth section of the Firebase console.

    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)signInAnonymouslyWithCompletion:(nullable FIRAuthDataResultCallback)completion;

/** @fn signInAnonymouslyAndRetrieveDataWithCompletion:
    @brief `Please use sign `signInAnonymouslyWithCompletion:` for Objective-C or
        `signInAnonymously(Completion:)` for Swift instead.
    @param completion Optionally; a block which is invoked when the sign in finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.
 */
- (void)signInAnonymouslyAndRetrieveDataWithCompletion:
    (nullable FIRAuthDataResultCallback)completion
        DEPRECATED_MSG_ATTRIBUTE("Please use signInAnonymouslyWithCompletion: for Objective-C or"
        " signInAnonymously(Completion:) for swift instead.");

/** @fn signInWithCustomToken:completion:
    @brief Asynchronously signs in to Firebase with the given Auth token.

    @param token A self-signed custom auth token.
    @param completion Optionally; a block which is invoked when the sign in finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidCustomToken` - Indicates a validation error with
            the custom token.
        + `FIRAuthErrorCodeCustomTokenMismatch` - Indicates the service account and the API key
            belong to different projects.



    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)signInWithCustomToken:(NSString *)token
                   completion:(nullable FIRAuthDataResultCallback)completion;

/** @fn signInAndRetrieveDataWithCustomToken:completion:
    @brief Please use `signInWithCustomToken:completion:` or `signIn(withCustomToken:completion:)`
        for Swift instead.

    @param token A self-signed custom auth token.
    @param completion Optionally; a block which is invoked when the sign in finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.
 */
- (void)signInAndRetrieveDataWithCustomToken:(NSString *)token
                                  completion:(nullable FIRAuthDataResultCallback)completion
                                      DEPRECATED_MSG_ATTRIBUTE(
                                      "Please use signInWithCustomToken:completion:"
                                      "for Objective-C or signIn(withCustomToken:completion:) for"
                                      " Swift instead.");

/** @fn createUserWithEmail:password:completion:
    @brief Creates and, on success, signs in a user with the given email address and password.

    @param email The user's email address.
    @param password The user's desired password.
    @param completion Optionally; a block which is invoked when the sign up flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.
        + `FIRAuthErrorCodeEmailAlreadyInUse` - Indicates the email used to attempt sign up
            already exists. Call fetchProvidersForEmail to check which sign-in mechanisms the user
            used, and prompt the user to sign in with one of those.
        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that email and password accounts
            are not enabled. Enable them in the Auth section of the Firebase console.
        + `FIRAuthErrorCodeWeakPassword` - Indicates an attempt to set a password that is
            considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
            dictionary object will contain more detailed explanation that can be shown to the user.

    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                 completion:(nullable FIRAuthDataResultCallback)completion;

/** @fn createUserAndRetrieveDataWithEmail:password:completion:
    @brief Please use `createUserAndRetrieveDataWithEmail:password:completion:` or
        `createUser(withEmail:password:completion:)` for Swift instead.

    @param email The user's email address.
    @param password The user's desired password.
    @param completion Optionally; a block which is invoked when the sign up flow finishes, or is
        canceled. Invoked asynchronously on the main thread in the future.
 */
- (void)createUserAndRetrieveDataWithEmail:(NSString *)email
                                  password:(NSString *)password
                                completion:(nullable FIRAuthDataResultCallback)completion
                                    DEPRECATED_MSG_ATTRIBUTE(
                                      "Please use createUserWithEmail:password:completion: for"
                                      " Objective-C or createUser(withEmail:password:completion:)"
                                      " for Swift instead.");

/** @fn confirmPasswordResetWithCode:newPassword:completion:
    @brief Resets the password given a code sent to the user outside of the app and a new password
      for the user.

    @param newPassword The new password.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeWeakPassword` - Indicates an attempt to set a password that is
            considered too weak.
        + `FIRAuthErrorCodeOperationNotAllowed` - Indicates the administrator disabled sign
            in with the specified identity provider.
        + `FIRAuthErrorCodeExpiredActionCode` - Indicates the OOB code is expired.
        + `FIRAuthErrorCodeInvalidActionCode` - Indicates the OOB code is invalid.

    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.
 */
- (void)confirmPasswordResetWithCode:(NSString *)code
                         newPassword:(NSString *)newPassword
                          completion:(FIRConfirmPasswordResetCallback)completion;

/** @fn checkActionCode:completion:
    @brief Checks the validity of an out of band code.

    @param code The out of band code to check validity.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.
 */
- (void)checkActionCode:(NSString *)code completion:(FIRCheckActionCodeCallBack)completion;

/** @fn verifyPasswordResetCode:completion:
    @brief Checks the validity of a verify password reset code.

    @param code The password reset code to be verified.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.
 */
- (void)verifyPasswordResetCode:(NSString *)code
                     completion:(FIRVerifyPasswordResetCodeCallback)completion;

/** @fn applyActionCode:completion:
    @brief Applies out of band code.

    @param code The out of band code to be applied.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.

    @remarks This method will not work for out of band codes which require an additional parameter,
        such as password reset code.
 */
- (void)applyActionCode:(NSString *)code
             completion:(FIRApplyActionCodeCallback)completion;

/** @fn sendPasswordResetWithEmail:completion:
    @brief Initiates a password reset for the given email address.

    @param email The email address of the user.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidRecipientEmail` - Indicates an invalid recipient email was
            sent in the request.
        + `FIRAuthErrorCodeInvalidSender` - Indicates an invalid sender email is set in
            the console for this action.
        + `FIRAuthErrorCodeInvalidMessagePayload` - Indicates an invalid email template for
            sending update email.


 */
- (void)sendPasswordResetWithEmail:(NSString *)email
                        completion:(nullable FIRSendPasswordResetCallback)completion;

/** @fn sendPasswordResetWithEmail:actionCodeSetting:completion:
    @brief Initiates a password reset for the given email address and @FIRActionCodeSettings object.

    @param email The email address of the user.
    @param actionCodeSettings An `FIRActionCodeSettings` object containing settings related to
        handling action codes.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeInvalidRecipientEmail` - Indicates an invalid recipient email was
            sent in the request.
        + `FIRAuthErrorCodeInvalidSender` - Indicates an invalid sender email is set in
            the console for this action.
        + `FIRAuthErrorCodeInvalidMessagePayload` - Indicates an invalid email template for
            sending update email.
        + `FIRAuthErrorCodeMissingIosBundleID` - Indicates that the iOS bundle ID is missing when
            `handleCodeInApp` is set to YES.
        + `FIRAuthErrorCodeMissingAndroidPackageName` - Indicates that the android package name
            is missing when the `androidInstallApp` flag is set to true.
        + `FIRAuthErrorCodeUnauthorizedDomain` - Indicates that the domain specified in the
            continue URL is not whitelisted in the Firebase console.
        + `FIRAuthErrorCodeInvalidContinueURI` - Indicates that the domain specified in the
            continue URI is not valid.


 */
 - (void)sendPasswordResetWithEmail:(NSString *)email
                 actionCodeSettings:(FIRActionCodeSettings *)actionCodeSettings
                         completion:(nullable FIRSendPasswordResetCallback)completion;

/** @fn sendSignInLinkToEmail:actionCodeSettings:completion:
    @brief Sends a sign in with email link to provided email address.

    @param email The email address of the user.
    @param actionCodeSettings An `FIRActionCodeSettings` object containing settings related to
        handling action codes.
    @param completion Optionally; a block which is invoked when the request finishes. Invoked
        asynchronously on the main thread in the future.
 */
- (void)sendSignInLinkToEmail:(NSString *)email
           actionCodeSettings:(FIRActionCodeSettings *)actionCodeSettings
                   completion:(nullable FIRSendSignInLinkToEmailCallback)completion;

/** @fn signOut:
    @brief Signs out the current user.

    @param error Optionally; if an error occurs, upon return contains an NSError object that
        describes the problem; is nil otherwise.
    @return @YES when the sign out request was successful. @NO otherwise.

    @remarks Possible error codes:

        + `FIRAuthErrorCodeKeychainError` - Indicates an error occurred when accessing the
            keychain. The `NSLocalizedFailureReasonErrorKey` field in the `NSError.userInfo`
            dictionary will contain more information about the error encountered.



 */
- (BOOL)signOut:(NSError *_Nullable *_Nullable)error;

/** @fn isSignInWithEmailLink
    @brief Checks if link is an email sign-in link.

    @param link The email sign-in link.
    @return @YES when the link passed matches the expected format of an email sign-in link.
 */
- (BOOL)isSignInWithEmailLink:(NSString *)link;

/** @fn addAuthStateDidChangeListener:
    @brief Registers a block as an "auth state did change" listener. To be invoked when:

      + The block is registered as a listener,
      + A user with a different UID from the current user has signed in, or
      + The current user has signed out.

    @param listener The block to be invoked. The block is always invoked asynchronously on the main
        thread, even for it's initial invocation after having been added as a listener.

    @remarks The block is invoked immediately after adding it according to it's standard invocation
        semantics, asynchronously on the main thread. Users should pay special attention to
        making sure the block does not inadvertently retain objects which should not be retained by
        the long-lived block. The block itself will be retained by `FIRAuth` until it is
        unregistered or until the `FIRAuth` instance is otherwise deallocated.

    @return A handle useful for manually unregistering the block as a listener.
 */
- (FIRAuthStateDidChangeListenerHandle)addAuthStateDidChangeListener:
    (FIRAuthStateDidChangeListenerBlock)listener;

/** @fn removeAuthStateDidChangeListener:
    @brief Unregisters a block as an "auth state did change" listener.

    @param listenerHandle The handle for the listener.
 */
- (void)removeAuthStateDidChangeListener:(FIRAuthStateDidChangeListenerHandle)listenerHandle;

/** @fn addIDTokenDidChangeListener:
    @brief Registers a block as an "ID token did change" listener. To be invoked when:

      + The block is registered as a listener,
      + A user with a different UID from the current user has signed in,
      + The ID token of the current user has been refreshed, or
      + The current user has signed out.

    @param listener The block to be invoked. The block is always invoked asynchronously on the main
        thread, even for it's initial invocation after having been added as a listener.

    @remarks The block is invoked immediately after adding it according to it's standard invocation
        semantics, asynchronously on the main thread. Users should pay special attention to
        making sure the block does not inadvertently retain objects which should not be retained by
        the long-lived block. The block itself will be retained by `FIRAuth` until it is
        unregistered or until the `FIRAuth` instance is otherwise deallocated.

    @return A handle useful for manually unregistering the block as a listener.
 */
- (FIRIDTokenDidChangeListenerHandle)addIDTokenDidChangeListener:
    (FIRIDTokenDidChangeListenerBlock)listener;

/** @fn removeIDTokenDidChangeListener:
    @brief Unregisters a block as an "ID token did change" listener.

    @param listenerHandle The handle for the listener.
 */
- (void)removeIDTokenDidChangeListener:(FIRIDTokenDidChangeListenerHandle)listenerHandle;

/** @fn useAppLanguage
    @brief Sets `languageCode` to the app's current language.
 */
- (void)useAppLanguage;

#if TARGET_OS_IOS

/** @fn canHandleURL:
    @brief Whether the specific URL is handled by `FIRAuth` .
    @param URL The URL received by the application delegate from any of the openURL method.
    @return Whether or the URL is handled. YES means the URL is for Firebase Auth
        so the caller should ignore the URL from further processing, and NO means the
        the URL is for the app (or another libaray) so the caller should continue handling
        this URL as usual.
    @remarks If swizzling is disabled, URLs received by the application delegate must be forwarded
        to this method for phone number auth to work.
 */
- (BOOL)canHandleURL:(nonnull NSURL *)URL;

/** @fn setAPNSToken:type:
    @brief Sets the APNs token along with its type.
    @remarks If swizzling is disabled, the APNs Token must be set for phone number auth to work,
        by either setting calling this method or by setting the `APNSToken` property.
 */
- (void)setAPNSToken:(NSData *)token type:(FIRAuthAPNSTokenType)type;

/** @fn canHandleNotification:
    @brief Whether the specific remote notification is handled by `FIRAuth` .
    @param userInfo A dictionary that contains information related to the
        notification in question.
    @return Whether or the notification is handled. YES means the notification is for Firebase Auth
        so the caller should ignore the notification from further processing, and NO means the
        the notification is for the app (or another libaray) so the caller should continue handling
        this notification as usual.
    @remarks If swizzling is disabled, related remote notifications must be forwarded to this method
        for phone number auth to work.
 */
- (BOOL)canHandleNotification:(NSDictionary *)userInfo;

#endif  // TARGET_OS_IOS

@end

NS_ASSUME_NONNULL_END
