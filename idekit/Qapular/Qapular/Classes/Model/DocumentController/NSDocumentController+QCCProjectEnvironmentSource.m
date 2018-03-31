//
//  NSDocumentController+QCCProjectEnvironmentSource.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2015 Qapular. All rights reserved.
//

#import "NSDocumentController+QCCProjectEnvironmentSource.h"

@implementation NSDocumentController (QCCProjectEnvironmentSource)

#pragma mark - QCCProjectEnvironmentSource
-(NSArray *)clangOptionsForFileOptions:(NSDictionary *)fileOptions {
    return [self clangOptions];
}

// Default  clang options
- (NSArray *) clangOptions {
    
    static  NSMutableArray *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = [[NSMutableArray alloc] init];
        
        [options addObjectsFromArray:[self includeClangOptions]];
        [options addObjectsFromArray:[self stdClangOptions]];
        [options addObjectsFromArray:[self optimizationsClangOptions]];
        [options addObjectsFromArray:[self isysrootClangOptions]];
        /* [options addObjectsFromArray:[self archClangOptions]]; */
        [options addObjectsFromArray:[self warningClangOptions]];
        
    });
    
    return options;
}


- (NSArray *) includeClangOptions {
    return @[
             @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/",
             @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/c++/",
             @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/",
             @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/sys/",
             @"-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include"
             ];
}


- (NSArray *) stdClangOptions{
    // supported modes for C are c89, gnu89, c94, c99, gnu99, c11, gnu11
    // return @[@"-std=c11"];
    return @[];
}


- (NSArray *) optimizationsClangOptions{
    return @[@"-O0"];
}


- (NSArray *) isysrootClangOptions{
    // /usr/bin/xcrun --show-sdk-path
    return @[@"-isysroot/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk"];
}


- (NSArray *) archClangOptions{
    return @[@"-arch x86_64"];
}


- (NSArray *) warningClangOptions{
    
    return @[@"-Wno-pedantic", // Warn on language extensions.
             @"-Wimplicit-function-declaration",
             @"-Weverything",
             @"-Wno-missing-field-initializers",
             @"-Wno-missing-prototypes",
             @"-Wno-missing-braces",
             @"-Wall"];
}

/*
 -Wnon-modular-include-in-framework-module
 -Wno-trigraphs
 -Wno-implicit-atomic-properties
 -Wno-receiver-is-weak
 -Wno-arc-repeated-use-of-weak
 -Wno-unused-label
 -Wno-unused-parameter
 -Wno-unknown-pragmas
 -Wno-shadow
 -Wno-four-char-constants
 -Wno-conversion
 -Wno-newline-eof
 -Wno-selector
 -Wno-strict-selector-match
 -Wno-deprecated-implementations
 -Wno-sign-conversion
 
 -Werror=non-modular-include-in-framework-module
 -Werror=return-type
 -Wunreachable-code
 -Werror=deprecated-objc-isa-usage
 -Werror=objc-root-class
 -Wduplicate-method-match
 -Wparentheses
 -Wswitch
 -Wunused-function
 -Wunused-variable
 -Wunused-value
 -Wempty-body
 -Wconditional-uninitialized
 -Wconstant-conversion
 -Wint-conversion
 -Wbool-conversion
 -Wenum-conversion
 -Wshorten-64-to-32
 -Wpointer-sign
 -Wundeclared-selector
 -Wprotocol
 -Wdeprecated-declarations
 */
@end
