//
//  QCCPackage.h
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import <QCCTargetManagerKit/QCCTargetManagerKit.h>

extern NSString * __nonnull const QCCPackageContainerKey;

@interface QCCPackage : QCCBasePackage

- (nullable id) valueForPackageKey:(nonnull NSString *) packageKey;

- (nullable NSDictionary <NSString *, NSString * >*) containerDictionary;

- (nullable NSString *) containerPathForKey:(nonnull NSString *) containerKey;
@end
