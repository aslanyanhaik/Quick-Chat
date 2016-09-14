// clang-format off
/** @file FIRStorageConstants.h
    @brief Firebase SDK
    @copyright Copyright 2016 Google Inc.
    @remarks Use of this SDK is subject to the Google APIs Terms of Service:
    https://developers.google.com/terms/
 */
// clang-format on

#import <Foundation/Foundation.h>

@class FIRStorageDownloadTask;
@class FIRStorageMetadata;
@class FIRStorageTaskSnapshot;
@class FIRStorageUploadTask;

NS_ASSUME_NONNULL_BEGIN

/**
 * NSString typedef representing a task listener handle.
 */
typedef NSString *FIRStorageHandle;

/**
 * Block typedef typically used when downloading data.
 * @param data The data returned by the download, or nil if no data available or download failed.
 * @param error The error describing failure, if one occurred.
 */
typedef void (^FIRStorageVoidDataError)(NSData *_Nullable data, NSError *_Nullable error);

/**
 * Block typedef typically used when performing "binary" async operations such as delete,
 * where the operation either succeeds without an error or fails with an error.
 * @param error The error describing failure, if one occurred.
 */
typedef void (^FIRStorageVoidError)(NSError *_Nullable error);

/**
 * Block typedef typically used when retrieving metadata.
 * @param metadata The metadata returned by the operation, if metadata exists.
 */
typedef void (^FIRStorageVoidMetadata)(FIRStorageMetadata *_Nullable metadata);

/**
 * Block typedef typically used when retrieving metadata with the possibility of an error.
 * @param metadata The metadata returned by the operation, if metadata exists.
 * @param error The error describing failure, if one occurred.
 */
typedef void (^FIRStorageVoidMetadataError)(FIRStorageMetadata *_Nullable metadata,
                                            NSError *_Nullable error);

/**
 * Block typedef typically used when getting or updating metadata with the possibility of an error.
 * @param metadata The metadata returned by the operation, if metadata exists.
 * @param error The error describing failure, if one occurred.
 */
typedef void (^FIRStorageVoidSnapshot)(FIRStorageTaskSnapshot *snapshot);

/**
 * Block typedef typically used when retrieving a download URL.
 * @param URL The download URL associated with the operation.
 * @param error The error describing failure, if one occurred.
 */
typedef void (^FIRStorageVoidURLError)(NSURL *_Nullable URL, NSError *_Nullable error);

/**
 * Enum representing the upload and download task status.
 */
typedef NS_ENUM(NSInteger, FIRStorageTaskStatus) {
  /**
   * Unknown task status.
   */
  FIRStorageTaskStatusUnknown,

  /**
   * Task is being resumed.
   */
  FIRStorageTaskStatusResume,

  /**
   * Task reported a progress event.
   */
  FIRStorageTaskStatusProgress,

  /**
   * Task is paused.
   */
  FIRStorageTaskStatusPause,

  /**
   * Task has completed successfully.
   */
  FIRStorageTaskStatusSuccess,

  /**
   * Task has failed and is unrecoverable.
   */
  FIRStorageTaskStatusFailure
};

/**
 * Firebase Storage error domain.
 */
FOUNDATION_EXPORT NSString *const FIRStorageErrorDomain;

/**
 * Enum representing the errors raised by Firebase Storage.
 */
typedef NS_ENUM(NSInteger, FIRStorageErrorCode) {
  FIRStorageErrorCodeUnknown = -13000,
  FIRStorageErrorCodeObjectNotFound = -13010,
  FIRStorageErrorCodeBucketNotFound = -13011,
  FIRStorageErrorCodeProjectNotFound = -13012,
  FIRStorageErrorCodeQuotaExceeded = -13013,
  FIRStorageErrorCodeUnauthenticated = -13020,
  FIRStorageErrorCodeUnauthorized = -13021,
  FIRStorageErrorCodeRetryLimitExceeded = -13030,
  FIRStorageErrorCodeNonMatchingChecksum = -13031,
  FIRStorageErrorCodeDownloadSizeExceeded = -13032,
  FIRStorageErrorCodeCancelled = -13040
};

NS_ASSUME_NONNULL_END
