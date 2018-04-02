//
//  QCCBasePackage.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString *const QCCPackageNameKey;
extern  NSString *const QCCPackageDescriptionKey;

extern  NSString *const QCCPackageURLKey;
extern  NSString *const QCCPackageVersionKey;
extern  NSString *const QCCPackageContentVersionKey;
extern  NSString *const QCCPackageIdentifierKey;
extern  NSString *const QCCPackageMD5HashKey;

typedef enum : NSUInteger {
    QCCPackageDownloadStateUnknown,
    QCCPackageDownloadStateIsInProgress,
    QCCPackageDownloadStateFinish,
    QCCPackageDownloadStateCancel,
    QCCPackageDownloadStateError
} QCCPackageDownloadState;

typedef enum : NSUInteger {
    QCCPackageUnpackStateUnknown,
    QCCPackageUnpackStateIsInProgress,
    QCCPackageUnpackStateFinish,
    QCCPackageUnpackStateCancel,
    QCCPackageUnpackStateError
} QCCPackageUnpackState;

typedef enum : NSUInteger {
    QCCPackageInstallStateUnknown,
    QCCPackageInstallStateDownload,
    QCCPackageInstallStateUnpack,
    QCCPackageInstallStateSuccessFinish,
    QCCPackageInstallStateFinishWithError
} QCCPackageInstallState;

@interface QCCBasePackage : NSObject {

    NSArray     *_urlArray;
    NSNumber    *_version;
    NSNumber    *_contentVersion;
    NSString    *_identifier;
    NSString    *_md5Hash;
    
    NSDictionary    *_rawContentDictionary;
}


@property (nonatomic, copy) void (^ downloadProgressBlock)(QCCPackageDownloadState state, NSError *error, int64_t totalBytesWritten, int64_t expectedTotalBytes);
@property (nonatomic, copy) void (^ unpackProgressBlock)(QCCPackageUnpackState state);


-(instancetype)initWithDictionary:(NSDictionary *) dictionary;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *packageDescription;

@property (nonatomic, readonly) NSArray     *urlArray;
@property (nonatomic, readonly) NSNumber    *version;
@property (nonatomic, readonly) NSNumber    *contentVersion;
@property (nonatomic, readonly) NSString    *identifier;
@property (nonatomic, readonly) NSString    *md5Hash;

@property (nonatomic, readonly) BOOL        isInstalled;


- (BOOL) installWithStateBlock:(void (^)(QCCBasePackage *package, QCCPackageInstallState state, NSError *error)) progressBlock;
- (BOOL) uninstall;
- (NSString *) installedURLString;

+ (NSString *) storageFolder;
- (NSString *) packageFolder;
@end
