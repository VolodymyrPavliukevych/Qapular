//
//  CKTypes.h
//  ClangKit
//
//  Created by Qapular on 3/22/14.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#ifndef ClangKit_CKTypes_h
#define ClangKit_CKTypes_h

#ifndef LLVM_CLANG_C_INDEX_H

/*!
 * @typedef         CXDiagnostic
 * @abstract        libclang type for diagnostic objects.
 */
typedef void * CXDiagnostic;

/*!
 * @typedef         CXIndex
 * @abstract        libclang type for index objects.
 */
typedef void * CXIndex;

/*!
 * @typedef         CXTranslationUnit
 * @abstract        libclang type for translation unit objects.
 */
typedef struct CXTranslationUnitImpl * CXTranslationUnit;

/*!
 * @typedef         CXFile
 * @abstract        libclang type for file objects.
 */
typedef void * CXFile;

/*!
 * @typedef         CXCompletionString
 * @abstract        libclang type for completion strings.
 */
typedef void * CXCompletionString;

#endif

/*!
 * @typedef         CKLanguage
 * @abstract        Source code languages
 * @discussion      ClangKit can be used to parse strings and files. For a file,
 *                  the language is guessed from the file's extension. For
 *                  strings, the language must be specified using one of this
 *                  value.
 */
typedef enum {
    CKLanguageNone   = 0x00,    /*! Unknown language */
    CKLanguageC      = 0x01,    /*! C source code */
    CKLanguageCPP    = 0x02,    /*! C++ source code */
    CKLanguageObjC   = 0x03,    /*! Objective-C source code */
    CKLanguageObjCPP = 0x04     /*! Objective-C++ source code */
}
CKLanguage;

#endif
