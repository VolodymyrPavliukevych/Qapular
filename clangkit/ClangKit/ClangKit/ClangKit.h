//
//  ClangKit.h
//  ClangKit
//
//  Created by Qapular on 3/23/14.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for ClangKit.
FOUNDATION_EXPORT double ClangKitVersionNumber;

//! Project version string for ClangKit.
FOUNDATION_EXPORT const unsigned char ClangKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ClangKit/PublicHeader.h>
#import <ClangKit/CKTypes.h>
#import <ClangKit/CKIndex.h>
#import <ClangKit/CKTranslationUnit.h>
#import <ClangKit/CKToken.h>
#import <ClangKit/CKCursor.h>
#import <ClangKit/CKSourceLocation.h>
#import <ClangKit/CKDiagnostic.h>
#import <ClangKit/CKFixItManager.h>
