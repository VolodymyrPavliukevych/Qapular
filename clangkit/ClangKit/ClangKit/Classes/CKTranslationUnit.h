//
//  CKTranslationUnit.h
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//


@class CKIndex;


typedef enum : NSUInteger {
    CKTranslationUnitErrorIsNil = 100,
} CKTranslationUnitError;

/*!
 * @class           CKTranslationUnit
 * @abstract        Translation unit class
 */


@interface CKTranslationUnit : NSObject {

@protected
    
    CKIndex           * _index;
    char             ** _args;
    int                 _numArgs;
//    NSArray           * _diagnostics;
//    NSArray           * _tokens;
//    void              * _tokensPointer;
//    void              * _unsavedFile;
    NSLock            * _lock;

}

/*!
 * @property        cxTranslationUnit
 * @abstract        Internal libclang translation unit object
 */

@property(atomic, readonly) CXTranslationUnit cxTranslationUnit;

extern NSString *const CKTranslationUnitUnSavedFilenameKey;
extern NSString *const CKTranslationUnitUnSavedContentKey;

/** Provide translation unit instance.
 
 Main init methiod.
 
 @return	instance of class.
 @param	path	Full path to parsed file. Can't be nil.
 @param content Content of unsaved parsed file. Can be nil.
 @param files   Array with ansaved files needed for providing code-completition.
 @param index   CKIndex index storage for translation unit.
 @param args    Array of NSString with clang arguments.
 @warning	You have to set path and if path file is empty content must be not nil.
 */

- (id) initWithFilePath:(NSString *) path fileContent:(NSString *) content unSavedFiles:(NSArray *) files index:(CKIndex *) index args:(NSArray *) args;

- (NSArray *) tokens;
- (NSArray *) diagnostics;
- (NSArray *) tokensForRange:(NSRange) range;

- (CXFile) cxFile;

- (NSUInteger) fileLength;

- (NSError *) reparseUnitWithUnSavedFiles:(NSArray *) files;

- (NSArray *) includes;

/*!
 * @property        fileName
 * @abstract        The source location's filename
 */
@property(atomic, readonly) NSString * fileName;

@end

