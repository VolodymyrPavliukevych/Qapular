//
//  QCCFamilyAnalyser.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFamilyAnalyser.h"

#import "QCCHighlighter.h"
#import "QCCodeStorage.h"
#import "QCCThemaManager.h"
#import "QCCFamilyHighlighter.h"
#import "QCCFamilyDocument.h"
#import "QCCBaseDocument+UTType.h"

#import <ClangKit/ClangKit.h>

typedef enum : NSUInteger {
    AnalyserErrorCanNotCreateTranslationUnit
} AnalyserError;

@interface QCCFamilyAnalyser() {
    
    NSArray                 *_clangArgs;
    NSString                *_filePathString;
    CKTranslationUnit       *_translationUnit;
    dispatch_queue_t        _translationUnitQueue;
    
}

@end

@implementation QCCFamilyAnalyser

NSString *const QCCSpaceChar = @" ";
NSString *const QCCNewLineChar = @"\n";

- (instancetype) initForDocument:(QCCFamilyDocument *) document
                    themaManager:(QCCThemaManager *) themaManager
        projectEnvironmentSource:(id <QCCProjectEnvironmentSource>) projectEnvironmentSource {
    
    self = [super initForCodeStorage:document.codeStorage
                        themaManager:themaManager];
    
    if (self) {
        _translationUnitQueue = dispatch_queue_create("TranslationUnitQueue", 0);
        _projectEnvironmentSource = projectEnvironmentSource;
        NSString *filePath = (document.fileURL ? document.fileURL.path : document.autosavedContentsFileURL.path);

        _filePathString = filePath;
        
        if (_projectEnvironmentSource && [_projectEnvironmentSource respondsToSelector:@selector(clangOptionsForFileOptions:)])
            _clangArgs = [_projectEnvironmentSource clangOptionsForFileOptions:@{QCCProjectEnvironmentSourceDocumentUTTypeOptionKey : document.UTIString}];
        else
            _clangArgs = [NSArray new];

        BOOL parseResult = [self createTranslationUnit:^(NSError *error, NSArray *tokens) {
            if (error) {
                NSLog(@"Error:%@", error);
            }
            
            _highlighter = [[QCCFamilyHighlighter alloc] initWithCodeStorage:_codeStorage themaManager:_themaManager];
            [_highlighter highlighteByTokenArray:tokens];
        }];
        
        if (!parseResult)
            return nil;

    }
    
    return self;
}

- (void) setClangArgs:(NSArray *) args {

    if (args)
        _clangArgs = args;
    
}


#pragma mark - ClangKit 
- (BOOL) createTranslationUnit:(void (^)(NSError *error, NSArray *tokens)) completBlock {

    if (!_codeStorage || !_filePathString || !_clangArgs)
        return NO;

    [self analyzeExecutionBlock:^{

        _translationUnit = [[CKTranslationUnit alloc] initWithFilePath:_filePathString
                                                           fileContent:_codeStorage.string
                                                          unSavedFiles:nil
                                                                 index:nil
                                                                  args:_clangArgs];
    } completeBlockOnMainQueue:^{
        if (!_translationUnit) {
            NSError *error = [QCCFamilyAnalyser errorWithID:AnalyserErrorCanNotCreateTranslationUnit];
            completBlock(error, nil);
        }else
            completBlock(nil, _translationUnit.tokens);
    }];

    
    return YES;
}

#pragma mark - Rebuild
- (BOOL) reparseTranslationUnitForRange:(NSRange) range {
    __block NSError *reparseError;
    
    [self analyzeExecutionBlock:^{
        reparseError = [_translationUnit reparseUnitWithUnSavedFiles:@[@{CKTranslationUnitUnSavedFilenameKey : _filePathString,
                                                                         CKTranslationUnitUnSavedContentKey : _codeStorage.string}]];
    } completeBlockOnMainQueue:^{
        
        if (!reparseError) {
            NSRange relatedRange = [self relatedLexicalBlockForRange:range];

            /*
            NSLayoutManager *manager  = [[_codeStorage layoutManagers] firstObject];
            [manager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, _codeStorage.string.length)];
            [manager addTemporaryAttributes:@{NSBackgroundColorAttributeName : [NSColor cyanColor]} forCharacterRange:relatedRange];
            */
            
            NSArray *tokens = [_translationUnit tokensForRange:relatedRange];
            [_highlighter highlighteByTokenArray:tokens];
            
            [_codeStorage removeAllMarkers];
            for (CKDiagnostic *diagnostic in _translationUnit.diagnostics) {
                /*
                 NSLog(@"diagnostic for file: %@ range:%@ message:%@ severity: %lu", diagnostic.sourceLocation.fileName.lastPathComponent, NSStringFromRange(diagnostic.range), diagnostic.spelling, diagnostic.severity);
                 */
                
                if ([_filePathString isEqualToString:diagnostic.sourceLocation.fileName]) {
                    [_codeStorage addMarkerOnLineWithType:[self markerTypeForDiagnosticSeverity:diagnostic.severity]
                                                  message:diagnostic.spelling
                                        forCharacterRange:diagnostic.range];
                }else {
                    
                }
            }
        }

        else
            NSLog(@"Can't reparse:%@", reparseError);
    }];
    
    return YES;
}


- (void) printPath:(CKCursor *) cursor level:(int) level type:(int) type {
    if (cursor.location.fileName)
        NSLog(@"file: %@ level: %i length: %lu type:%i", cursor.location.fileName, level, (unsigned long)cursor.location.fileName.length, type);
    else
        NSLog(@"empty filename");
    
    if (cursor.referenced) {
        NSLog(@"cursor.referenced");
        [self printPath:cursor.referenced level:(level +1) type:1];
    }
    
    if (cursor.canonical) {
        NSLog(@"cursor.canonical");
        [self printPath:cursor.referenced level:(level +1) type:2];
    }
    
}


- (QCCLineMarkerType) markerTypeForDiagnosticSeverity:(CKDiagnosticSeverity) severity{
    
    if (severity == CKDiagnosticSeverityIgnored)
        return QCCLineMarkerTypeIgnored;
    
    if (severity == CKDiagnosticSeverityNote)
        return QCCLineMarkerTypeNote;
    
    if (severity == CKDiagnosticSeverityWarning)
        return QCCLineMarkerTypeWarning;
    
    if (severity == CKDiagnosticSeverityError)
        return QCCLineMarkerTypeError;
    
    if (severity == CKDiagnosticSeverityFatal)
        return QCCLineMarkerTypeFatal;
    
    return QCCLineMarkerTypeNULL;
}

#pragma mark - NSTextStorageDelegate

- (void)textStorageWillProcessEditing:(NSNotification *)notification {
    
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    QCCodeStorage *codeStorage = notification.object;
    
    if (![codeStorage editedMask] & NSTextStorageEditedCharacters)
        return;
    
    NSString *editedString = [codeStorage.string substringWithRange:codeStorage.editedRange];
    
    if ([editedString containsString:QCCSpaceChar] || [editedString containsString:QCCNewLineChar])
        [self reparseTranslationUnitForRange:codeStorage.editedRange];
        
}


#pragma mark - Helper
+ (NSError *) errorWithID:(NSUInteger) errorID {
    NSString *description;
    
    switch (errorID) {
        case AnalyserErrorCanNotCreateTranslationUnit:
            description = @"Analyser can not create Translation Unit.";
            break;
            
        default:
            description = @"Unknown error.";
            break;
    }
    

    NSError *error = [[NSError alloc] initWithDomain:@"com.qapular" code:errorID userInfo:@{@"description": description}];
    
    return error;
    
}


- (NSRange) relatedLexicalBlockForRange:(NSRange) range {

    NSArray * bracketPairs = [_codeStorage signatureForType:QCCodeStorageSignatureForBracketPairs];
    NSRange relatedLexicalRange = NSMakeRange(NSNotFound, 0);
    
    // Case first: looking count of brackets.
    
    if ([bracketPairs count] < 5)
        return NSMakeRange(0, _codeStorage.string.length);
    

    // Case second: search closest brackets.
    for (NSDictionary *pair in bracketPairs) {
        NSUInteger openBracketIndex = [pair[@(QCCodeStorageSignatureForOpenBrackets)] unsignedIntegerValue];
        NSUInteger closedBracketIndex = [pair[@(QCCodeStorageSignatureForClosedBrackets)] unsignedIntegerValue];
        
        if (openBracketIndex < range.location && closedBracketIndex > NSMaxRange(range))
            relatedLexicalRange = NSMakeRange(openBracketIndex, closedBracketIndex - openBracketIndex);
    }
    
    if (relatedLexicalRange.location != NSNotFound)
        return  relatedLexicalRange;
    
    // Case three: search between different brackets bloks
    
    NSDictionary *previousPair;
    
    for (NSDictionary *pair in bracketPairs) {
        if (!previousPair) {
            previousPair = pair;
            continue;
        }
        NSNumber * previousOpenBracketIndex = previousPair[@(QCCodeStorageSignatureForOpenBrackets)];
        
        NSNumber * closedBracketIndex = pair[@(QCCodeStorageSignatureForClosedBrackets)];
        
        NSUInteger length = [closedBracketIndex unsignedIntegerValue] - [previousOpenBracketIndex unsignedIntegerValue];
        NSRange bracketRange = NSMakeRange([previousOpenBracketIndex unsignedIntegerValue], length);
        
        if (NSLocationInRange(range.location, bracketRange) && NSLocationInRange(range.location + range.length, bracketRange)) {
            relatedLexicalRange = bracketRange;
            return bracketRange;
        }
        
        previousPair = pair;
    }
    
    // Case fourth out of brackets
    NSDictionary *firstBracketPair = [bracketPairs firstObject];
    NSNumber * openBracketIndex = firstBracketPair[@(QCCodeStorageSignatureForOpenBrackets)];
    
    if (range.location + range.length < [openBracketIndex unsignedIntegerValue])
        return NSMakeRange(0, [openBracketIndex unsignedIntegerValue]);
    
    
    NSDictionary *lastBracketPair = [bracketPairs lastObject];
    NSNumber * closedBracketIndex = lastBracketPair[@(QCCodeStorageSignatureForClosedBrackets)];
    
    if (range.location > [closedBracketIndex unsignedIntegerValue])
        return NSMakeRange([closedBracketIndex unsignedIntegerValue], _codeStorage.string.length - [closedBracketIndex unsignedIntegerValue]);
    
    
    NSLog(@"Error, can't get right related range.");
    return NSMakeRange(0, _codeStorage.string.length);
}



@end
