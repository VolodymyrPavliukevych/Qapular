//
//  QCCPackageURL.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych on 2015
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCCPackage;

extern NSString * __nonnull const QCCPackageURLAnchorKey;
extern NSString * __nonnull const QCCPackageURLContainerAnchorKey;

@interface QCComplexURL : NSObject

- (nullable instancetype) initWithString:(nonnull NSString *) string packageManager:(QCCPackage * __nullable (^__nonnull)(NSString * __nonnull identifier)) managerBlock;
- (nullable instancetype) initWithString:(nonnull NSString *) string
                          packageManager:(QCCPackage * __nullable (^__nonnull)(NSString * __nonnull identifier)) managerBlock
                             environment:(NSString *__nullable (^__nonnull)(NSString * __nonnull environmentKey)) environmentBlock;

- (nonnull NSString *) fullPath;
- (nonnull NSArray *) processedComponents;
- (nonnull NSArray *) pathComponents;
- (nullable QCCPackage *) basePackage;
- (nullable NSString *) packageIdentifier;

@end
