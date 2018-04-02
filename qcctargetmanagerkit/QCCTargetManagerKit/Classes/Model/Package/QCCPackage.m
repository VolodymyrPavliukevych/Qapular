//
//  QCCPackage.m
//  QCCTargetManagerKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) Volodymyr Pavliukevych. All rights reserved.
//

#import "QCCPackage.h"

NSString *const QCCPackageToolKey = @"QCCPackageTool";

NSString *const QCCPackageGCCCompileToolKey             = @"QCCPackageGCCCompileTool";
NSString *const QCCPackageCPPCompileToolKey             = @"QCCPackageCPPCompileTool";
NSString *const QCCPackageASCompileToolKey              = @"QCCPackageASCompileTool";
NSString *const QCCPackageArchiveToolKey                = @"QCCPackageArchiveTool";
NSString *const QCCPackageObjCopyToolKey                = @"QCCPackageObjCopyTool";
NSString *const QCCPackageExecutableLinkableFormatToolKey = @"QCCPackageExecutableLinkableFormatTool";

NSString *const QCCPackageContainerKey          = @"QCCPackageContainer";

/* Depricated
 NSString *const QCCPackageIncludeKey            = @"QCCPackageInclude";
 NSString *const QCCPackageLibraryKey            = @"QCCPackageLibrary";
 NSString *const QCCPackageUploadToolKey         = @"QCCPackageUploadTool";
 NSString *const QCCPackageUploadToolConfigKey   = @"QCCPackageUploadToolConfig";
*/

@implementation QCCPackage

- (id) valueForPackageKey:(NSString *) packageKey {
    if(!packageKey)
        return nil;
    
    return _rawContentDictionary[packageKey];
}

- (nullable NSDictionary <NSString *, NSString * >*) containerDictionary {

    return _rawContentDictionary[QCCPackageContainerKey];
}

- (nullable NSString *) containerPathForKey:(nonnull NSString *) containerKey {
    if (containerKey.length == 0)
        return nil;
    return [self containerDictionary][containerKey];
}

@end
