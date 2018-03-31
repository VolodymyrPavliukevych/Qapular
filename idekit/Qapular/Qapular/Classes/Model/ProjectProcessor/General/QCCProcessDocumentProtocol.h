//
//  QCCProcessDocumentProtocol.h
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QCCProcessDocumentFlagNone              = 0,
    QCCProcessDocumentFlagStop              = 1 << 0,
    QCCProcessDocumentFlagClean             = 1 << 1,
    QCCProcessDocumentFlagBuild             = 1 << 2,
    QCCProcessDocumentFlagUploadOnTarget    = 1 << 3,
    QCCProcessDocumentFlagRunOnTarget       = 1 << 4,
    QCCProcessDocumentFlagEraseTarget       = 1 << 5,
    QCCProcessDocumentFlagFlashTarget       = 1 << 6
} QCCProcessDocumentFlag;


typedef enum : NSUInteger {
    QCCProcessDocumentMaskNone              = QCCProcessDocumentFlagNone,
    QCCProcessDocumentMaskStop              = QCCProcessDocumentFlagStop,
    QCCProcessDocumentMaskClean             = QCCProcessDocumentFlagClean,
    QCCProcessDocumentMaskBuild             = QCCProcessDocumentFlagBuild,
    QCCProcessDocumentMaskUploadOnTarget    = QCCProcessDocumentFlagUploadOnTarget,
    QCCProcessDocumentMaskRunOnTarget       = QCCProcessDocumentFlagRunOnTarget,
    QCCProcessDocumentMaskEraseTarget       = QCCProcessDocumentFlagEraseTarget,
    QCCProcessDocumentMaskFlashTarget       = QCCProcessDocumentFlagFlashTarget,
    QCCProcessDocumentFullBuild             = QCCProcessDocumentMaskStop | QCCProcessDocumentFlagClean | QCCProcessDocumentFlagBuild,
    QCCProcessDocumentFullUpload            = QCCProcessDocumentMaskStop | QCCProcessDocumentFlagClean | QCCProcessDocumentFlagBuild | QCCProcessDocumentFlagUploadOnTarget
} QCCProcessDocumentMask;



typedef void (^QCCProcessDocumentBlock)(QCCProcessDocumentMask processed,  NSError * _Nullable error);

@protocol QCCProcessDocumentProtocol <NSObject>
@required
- (BOOL) processDocument:(QCCProcessDocumentMask) processMask completionBlock:(nonnull QCCProcessDocumentBlock) completionBlock;
@end

@protocol QCCProcessReportProtocol <NSObject>

- (void) insertReportLine:(nonnull NSAttributedString *) reportLine;
- (void) clearReport;

@end


