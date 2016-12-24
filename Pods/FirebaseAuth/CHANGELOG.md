# 2016-12-13 -- v3.1.0
- Adds FIRAuth methods that enable the app to follow up with user actions
  delivered by email, such as verifying email address or reset password.
- No longer applies the keychain workaround introduced in v3.0.5 on iOS 10.2
  simulator or above since the issue has been fixed.
- Fixes nullability compilation warnings when used in Swift.
- Better reports missing password error.

# 2016-10-24 -- v3.0.6
- Switches to depend on open sourced GoogleToolboxForMac and GTMSessionFetcher.
- Improves logging of keychain error when initializing.

# 2016-09-14 -- v3.0.5
- Works around a keychain issue in iOS 10 simulator.
- Reports the correct error for invalid email when signing in with email and
  password.

# 2016-07-18 -- v3.0.4
- Fixes a race condition bug that could crash the app with an exception from
  NSURLSession on iOS 9.

# 2016-06-20 -- v3.0.3
- Adds documentation for all possible errors returned by each method.
- Improves error handling and messages for a variety of error conditions.
- Whether or not an user is considered anonymous is now consistent with other
  platforms.
- A saved signed in user is now siloed between different Firebase projects
  within the same app.

# 2016-05-18 -- v3.0.2
- Initial public release.
