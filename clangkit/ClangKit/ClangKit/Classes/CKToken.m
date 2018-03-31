//
//  CKToken.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "CKToken.h"

#import "CKCursor.h"
#import "CKSourceLocation.h"
#import "CKTranslationUnit.h"


CKTokenKind CKTokenKindPunctuation  = CXToken_Punctuation;
CKTokenKind CKTokenKindKeyword      = CXToken_Keyword;
CKTokenKind CKTokenKindIdentifier   = CXToken_Identifier;
CKTokenKind CKTokenKindLiteral      = CXToken_Literal;
CKTokenKind CKTokenKindComment      = CXToken_Comment;


@implementation CKToken

@synthesize spelling        = _spelling;
@synthesize kind            = _kind;
@synthesize line            = _line;
@synthesize column          = _column;
@synthesize range           = _range;
@synthesize cursor          = _cursor;
@synthesize sourceLocation  = _sourceLocation;


+ (NSArray *)tokensForTranslationUnit:(CKTranslationUnit *)translationUnit forRange:(NSRange) range tokens:(void **)tokensPointer {
    NSMutableArray * tokens;
    
    CXToken * cxTokens = NULL;
    CXFile  file = [translationUnit cxFile];
    
    if (file == NULL){
        NSLog(@"token file is empty");
        return nil;
    }
    
    unsigned int startIndex =  (unsigned int) range.location;
    unsigned int endIndex =  (unsigned int) NSMaxRange(range);
    
    CXSourceLocation startLocation   = clang_getLocationForOffset(translationUnit.cxTranslationUnit, file, startIndex);
    CXSourceLocation endLocation     = clang_getLocationForOffset(translationUnit.cxTranslationUnit, file, endIndex);
    CXSourceRange    sourceRange     = clang_getRange(startLocation, endLocation);
    unsigned int     numTokens       = 0;
    
    CKToken        * token;
    
    clang_tokenize(translationUnit.cxTranslationUnit, sourceRange, &cxTokens, &numTokens);
    
    if(numTokens == 0) {
        return nil;
    }
    
    clang_annotateTokens(translationUnit.cxTranslationUnit, cxTokens, numTokens, NULL);
    
    // Init token file name
    CXString cxfileName = clang_getFileName(file);
    const char * fileNameCString = clang_getCString(cxfileName);
    NSString *fileName;
    if(fileNameCString != NULL) {
        fileName = [[NSString alloc] initWithCString:fileNameCString encoding:NSUTF8StringEncoding];
    }
    clang_disposeString(cxfileName);
    
    
    tokens = [NSMutableArray arrayWithCapacity:(NSUInteger)numTokens];
    
    for(unsigned int i = 0; i < numTokens; i++) {
        
        token = [[CKToken alloc ] initWithCXToken: cxTokens[i] translationUnit:translationUnit cxFile:file fileName:fileName];
        
        if(token) {
            [tokens addObject:token];
        }
    }
    
    if(tokensPointer != NULL){
        *(tokensPointer) = (char *)cxTokens;
    }
    
    return [NSArray arrayWithArray: tokens];
}

+ (NSArray *)tokensForTranslationUnit:(CKTranslationUnit *)translationUnit tokens:(void **)tokensPointer {
    
    NSUInteger length = [translationUnit fileLength];
    NSRange range = NSMakeRange(0, length);
    
    return [CKToken tokensForTranslationUnit:translationUnit forRange:range tokens:tokensPointer];
}


- (id)initWithCXToken:(CXToken)token translationUnit:(CKTranslationUnit *)translationUnit cxFile:(CXFile) cxFile fileName:(NSString *) fileName {
    CXString         spelling;
    CXSourceRange    range;
    CXSourceLocation location;
    
    CXFile           file;
    unsigned int     line;
    unsigned int     column;
    unsigned int     offset;

    self = [self init];
    
    if(self) {
    
        spelling  = clang_getTokenSpelling(translationUnit.cxTranslationUnit, token);
        _spelling = [[NSString alloc] initWithCString:clang_getCString(spelling) encoding:NSUTF8StringEncoding];
        _kind     = clang_getTokenKind(token);
        location  = clang_getTokenLocation(translationUnit.cxTranslationUnit, token);
        range     = clang_getTokenExtent(translationUnit.cxTranslationUnit, token);
        
        clang_getExpansionLocation(location, &file, &line, &column, &offset);
        
        _line           = (NSUInteger)line;
        _column         = (NSUInteger)column;
        _range          = NSMakeRange((NSUInteger)offset, range.end_int_data - range.begin_int_data);
        
        
        _sourceLocation = [[CKSourceLocation alloc] initWithCXSourceLocationValue:[NSValue value:&location withObjCType:@encode(CXSourceLocation)]];
        _cursor         = [[CKCursor alloc] initWithLocation:_sourceLocation translationUnit:translationUnit];
        _fileName = fileName;
    
    }
    return self;
}


- (NSString *)description {
    
    NSString * description;
    NSString * kind;
    
    if( self.kind == CKTokenKindPunctuation) {
        kind = @"Punctuation: A token that contains some kind of punctuation.";
    } else if( self.kind == CKTokenKindKeyword) {
        kind = @"Keyword: A language keyword.";
    } else if( self.kind == CKTokenKindIdentifier) {
        kind = @"Identifier: An identifier (that is not a keyword)";
    } else if( self.kind == CKTokenKindLiteral) {
        kind = @"Literal: A numeric, string, or character literal.";
    } else if( self.kind == CKTokenKindComment) {
        kind = @"Comment: A comment.";
    } else {
        kind = @"Unknown";
    }
 
    description = [super description];
    
   
    description = [description stringByAppendingFormat: @" '%@'(\nKind is %@\nRange:%@\nCursor:%@\n)\n", _spelling, kind, NSStringFromRange(_range), _cursor];
   
    return description;
}

@end
