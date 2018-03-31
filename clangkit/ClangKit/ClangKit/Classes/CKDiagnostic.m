//
//  CKDiagnostic.m
//  ClangKit
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "CKDiagnostic.h"
#import "CKTranslationUnit.h"
#import "CKFixItManager.h"
#import "CKSourceLocation.h"

CKDiagnosticSeverity CKDiagnosticSeverityIgnored  = CXDiagnostic_Ignored;
CKDiagnosticSeverity CKDiagnosticSeverityNote     = CXDiagnostic_Note;
CKDiagnosticSeverity CKDiagnosticSeverityWarning  = CXDiagnostic_Warning;
CKDiagnosticSeverity CKDiagnosticSeverityError    = CXDiagnostic_Error;
CKDiagnosticSeverity CKDiagnosticSeverityFatal    = CXDiagnostic_Fatal;

@implementation CKDiagnostic

@synthesize cxDiagnostic    = _cxDiagnostic;
@synthesize spelling        = _spelling;
@synthesize severity        = _severity;
@synthesize fixIts          = _fixIts;
@synthesize line            = _line;
@synthesize column          = _column;
@synthesize range           = _range;

- (id)initWithCXDiagnostic:(CXDiagnostic)diagnostic translationUnit:(CKTranslationUnit *)translationUnit {
    
    CXString         spelling;
    CXSourceLocation location;
    CXSourceRange    range;
    CXFile              file;
    unsigned int     line;
    unsigned int     column;
    unsigned int     offset;
    
    if(diagnostic == NULL)
        return nil;
    
    
    self = [self init];
    
    if(self) {
        
        _cxDiagnostic = diagnostic;
        spelling      = clang_getDiagnosticSpelling(_cxDiagnostic);
        _spelling     = [[NSString alloc] initWithCString:clang_getCString(spelling) encoding: NSUTF8StringEncoding];
        _severity     = clang_getDiagnosticSeverity(_cxDiagnostic);
        
        clang_disposeString(spelling);
        
        location  = clang_getDiagnosticLocation(diagnostic);
        range     = clang_getDiagnosticRange(diagnostic, 0);
        
        _sourceLocation = [[CKSourceLocation alloc] initWithCXSourceLocationValue:[NSValue value:&location withObjCType:@encode(CXSourceLocation)]];
        
        clang_getExpansionLocation(location, &file, &line, &column, &offset);
        
        _line   = (NSUInteger)line;
        _column = (NSUInteger)column;
        _range  = NSMakeRange((NSUInteger)offset, range.end_int_data - range.begin_int_data);
        
        _fixIts = [CKFixItManager fixItsForDiagnostic:self];
    }
    
    return self;
}

+ (NSArray *) diagnosticsForTranslationUnit:(CKTranslationUnit *)translationUnit {
    unsigned int     numDiagnostics;
    unsigned int     i;
    NSMutableArray * diagnostics;
    CKDiagnostic   * diagnostic;
    
    numDiagnostics = clang_getNumDiagnostics(translationUnit.cxTranslationUnit);
    diagnostics    = [NSMutableArray arrayWithCapacity:(NSUInteger)numDiagnostics];
    
    for(i = 0; i < numDiagnostics; i++) {
        diagnostic = [CKDiagnostic diagnosticWithTranslationUnit:translationUnit index:i];
        
        if(diagnostic != nil) {
            [diagnostics addObject:diagnostic];
        }
    }
    
    return [NSArray arrayWithArray:diagnostics];
}

+ (id)diagnosticWithTranslationUnit:(CKTranslationUnit *)translationUnit index:(NSUInteger)index {
    
    CKDiagnostic *diagnostic = [[CKDiagnostic alloc] initWithTranslationUnit:(CKTranslationUnit *)translationUnit index:index];
    return diagnostic;
}

- (id)initWithTranslationUnit:(CKTranslationUnit *)translationUnit index:(NSUInteger)index {
    
    CXDiagnostic cxDiagnostic = clang_getDiagnostic(translationUnit.cxTranslationUnit, (unsigned int)index);
    
    self = [self initWithCXDiagnostic:cxDiagnostic translationUnit:translationUnit];
    
    if(self){
    
    }
    
    return self;
}

- (void) dealloc {
    clang_disposeDiagnostic(_cxDiagnostic);
}

- (NSString *)description {
    
    NSString * description;
    NSString * severity;
    
    if(self.severity == CKDiagnosticSeverityError)
        severity = @"Error";
    
    else if(self.severity == CKDiagnosticSeverityFatal)
        severity = @"Fatal";
    
    else if(self.severity == CKDiagnosticSeverityIgnored)
        severity = @"Ignored";
    
    else if(self.severity == CKDiagnosticSeverityNote)
        severity = @"Note";
    
    else if(self.severity == CKDiagnosticSeverityWarning)
        severity = @"Warning";
    
    else
        severity = @"Unknown";
    
    
    description = [super description];
    description = [description stringByAppendingFormat: @": %@[line: %lu column:%lu] - %@",
                   severity,
                   (unsigned long)(self.line),
                   (unsigned long)(self.column),
                   self.spelling];
    
    return description;
}


@end
