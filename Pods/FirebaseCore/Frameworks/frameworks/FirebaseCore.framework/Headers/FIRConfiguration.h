#import <Foundation/Foundation.h>

#import "FIRAnalyticsConfiguration.h"

/**
 * The log levels used by FIRConfiguration.
 */
typedef NS_ENUM(NSInteger, FIRLogLevel) {
  /** Error */
  kFIRLogLevelError __deprecated = 0,
  /** Warning */
  kFIRLogLevelWarning __deprecated,
  /** Info */
  kFIRLogLevelInfo __deprecated,
  /** Debug */
  kFIRLogLevelDebug __deprecated,
  /** Assert */
  kFIRLogLevelAssert __deprecated,
  /** Max */
  kFIRLogLevelMax __deprecated = kFIRLogLevelAssert
} DEPRECATED_MSG_ATTRIBUTE(
    "Use -FIRDebugEnabled and -FIRDebugDisabled. See FIRApp.h for more details.");

/**
 * This interface provides global level properties that the developer can tweak, and the singleton
 * of the Firebase Analytics configuration class.
 */
@interface FIRConfiguration : NSObject

/** Returns the shared configuration object. */
+ (FIRConfiguration *)sharedInstance;

/** The configuration class for Firebase Analytics. */
@property(nonatomic, readwrite) FIRAnalyticsConfiguration *analyticsConfiguration;

/** Global log level. Defaults to kFIRLogLevelError. */
@property(nonatomic, readwrite, assign) FIRLogLevel logLevel DEPRECATED_MSG_ATTRIBUTE(
    "Use -FIRDebugEnabled and -FIRDebugDisabled. See FIRApp.h for more details.");

@end
