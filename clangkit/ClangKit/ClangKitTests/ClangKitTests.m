//
//  ClangKitTests.m
//  ClangKitTests
//
//  Created by Qapular on 3/23/14.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "CKWarnings.h"

#import <XCTest/XCTest.h>
#import <ClangKit/ClangKit.h>


@interface ClangKitTests : XCTestCase {

    CKTranslationUnit   *_translationUnit;

}

@end

@implementation ClangKitTests

- (void)setUp {
    [super setUp];
    
    NSString *codeStringSecond = @"\n//First comment\n void funcc(){ return;}; /*Some comment*/\nint main(int val, float valSecond) {\n if(valSecond > 0.5) {\n  val++;\n }\nchar charVar = 'Q';\nprintf(\"%c\", charVar);\n  return val;\n }\n";
    NSString *filePathSecond = @"/Users/Roaming/Desktop/file0.c";
    
    NSString *codeStringFirst = @"int func(int aaIntArg)\n{\n aaIntArg++; \n printf(\"%i\", 'char')\nreturn aaintArg * 2;\n}\n";
    NSString *filePathFirst = @"/Users/Roaming/Desktop/file1.c";
    
    NSArray *args = @[/*@"-x c",*/
                      @"-std=gnu99", // supported modes for C are c89, gnu89, c94, c99, gnu99, c11, gnu11
                      @"-O0", 
                      @"-isysroot/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk",
                      @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/",
                      @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/c++/",
                      @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/",
                      @"-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/sys/",
                      @"-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include",
                      @"-arch x86_64",
                      @"-Weverything",
                      @"-Wall"
                      ];
                      
                  /*  
                   @"-F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks",
                   @"-F/Applications/Xcode.app/Contents/Developer/Library/Frameworks",
                   @"-include /path/to/Prefix.pch",
                   */
    
    /*
     sdkparam=`xcodebuild -showsdks | awk '/^$/{p=0};p; /OS X SDKs:/{p=1}' | tail -1 | cut -f3`
     sdkpath=`xcodebuild -version $sdkparam Path`
     */
    
    NSLog(@"start");
    _translationUnit = [[CKTranslationUnit alloc] initWithFilePath:filePathFirst
                                                       fileContent:codeStringFirst
                                                      unSavedFiles:@[@{CKTranslationUnitUnSavedFilenameKey : filePathSecond,
                                                                       CKTranslationUnitUnSavedContentKey : codeStringSecond}]
                                                             index:nil
                                                              args:args];
    
    NSLog(@"stop");
}


- (void) testTranslationUnitAlloc {

    XCTAssert((_translationUnit != NULL), @"Pass");
    
}
- (void)tearDown {
    [super tearDown];
}

- (void)testTokens {

    NSUInteger tokensCountFirst = [[_translationUnit tokens] count];

    NSLog(@"Tokens for first file: %lu", tokensCountFirst);
    
    // This is an example of a functional test case.
    XCTAssert((tokensCountFirst > 0), @"Pass");
    
}

- (void)testDiagnostics {

    NSArray *diagnostics = [_translationUnit diagnostics];
    NSLog(@"Diagnostics: %@", diagnostics);
    XCTAssert(([diagnostics count] != 0), @"Pass");

}

- (void) testFixIts {
    
    NSArray *diagnostics = [_translationUnit diagnostics];
    BOOL foundFixIt = NO;
    for (CKDiagnostic *diagnostic in diagnostics) {
        NSLog(@"diagnostic : %@", diagnostic);
        for (CKFixItManager *manager in  [diagnostic fixIts]) {
            foundFixIt = YES;
            NSLog(@"FixIt: %@ %@", manager, NSStringFromRange(manager.range));
        }
    }
    XCTAssert((foundFixIt), @"Pass");
}

- (void)testPerformanceReparseExample {
    // This is an example of a performance test case.
    NSString *filePathSecond = @"/Users/Roaming/Desktop/file0.c";
    NSString *codeStringSecond = @"\n//First comment\n void funcc(){ return;}; /*Some comment*/\nint main(int val, float valSecond) {\n if(valSecond > 0.5) {\n  val++; printf(\"that is new code\"); \n }\nchar charVar = 'Q';\nprintf(\"%c\", charVar);\n  return val;\n }\n";
    
    NSString *filePathFirst = @"/Users/Roaming/Desktop/file1.c";
    NSString *codeStringFirst = @"/*comment*/ void func(int a) {return;}";

    
    NSArray *unSavedFiles = @[@{CKTranslationUnitUnSavedFilenameKey : filePathFirst,
                         CKTranslationUnitUnSavedContentKey : codeStringFirst},
                              @{CKTranslationUnitUnSavedFilenameKey : filePathSecond,
                                CKTranslationUnitUnSavedContentKey : codeStringSecond}];
    
    [self measureBlock:^{
        NSError *error =  [_translationUnit reparseUnitWithUnSavedFiles:unSavedFiles];
        if (error)
            NSLog(@"Error:%@", error);
        
        NSUInteger count = [[_translationUnit tokensForRange:NSMakeRange(0, 25)] count];
        NSLog(@"Tokens for range: %lu", count);
        XCTAssert((!error), @"Pass");

    }];

}

@end
