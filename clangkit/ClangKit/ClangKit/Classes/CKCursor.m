//
//  CKCursor.m
//  ClangKit
//
//  Created by Qapular on 3/24/14.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#import "CKCursor.h"
#import "CKSourceLocation.h"
#import "CKTranslationUnit.h"
#import "NSString+NSStringFromBOOL.h"


CKCursorKind CKCursorKindUnexposedDecl                      = CXCursor_UnexposedDecl;
CKCursorKind CKCursorKindStructDecl                         = CXCursor_StructDecl;
CKCursorKind CKCursorKindUnionDecl                          = CXCursor_UnionDecl;
CKCursorKind CKCursorKindClassDecl                          = CXCursor_ClassDecl;
CKCursorKind CKCursorKindEnumDecl                           = CXCursor_EnumDecl;
CKCursorKind CKCursorKindFieldDecl                          = CXCursor_FieldDecl;
CKCursorKind CKCursorKindEnumConstantDecl                   = CXCursor_EnumConstantDecl;
CKCursorKind CKCursorKindFunctionDecl                       = CXCursor_FunctionDecl;
CKCursorKind CKCursorKindVarDecl                            = CXCursor_VarDecl;
CKCursorKind CKCursorKindParmDecl                           = CXCursor_ParmDecl;
CKCursorKind CKCursorKindObjCInterfaceDecl                  = CXCursor_ObjCInterfaceDecl;
CKCursorKind CKCursorKindObjCCategoryDecl                   = CXCursor_ObjCCategoryDecl;
CKCursorKind CKCursorKindObjCProtocolDecl                   = CXCursor_ObjCProtocolDecl;
CKCursorKind CKCursorKindObjCPropertyDecl                   = CXCursor_ObjCPropertyDecl;
CKCursorKind CKCursorKindObjCIvarDecl                       = CXCursor_ObjCIvarDecl;
CKCursorKind CKCursorKindObjCInstanceMethodDecl             = CXCursor_ObjCInstanceMethodDecl;
CKCursorKind CKCursorKindObjCClassMethodDecl                = CXCursor_ObjCClassMethodDecl;
CKCursorKind CKCursorKindObjCImplementationDecl             = CXCursor_ObjCImplementationDecl;
CKCursorKind CKCursorKindObjCCategoryImplDecl               = CXCursor_ObjCCategoryImplDecl;
CKCursorKind CKCursorKindTypedefDecl                        = CXCursor_TypedefDecl;
CKCursorKind CKCursorKindCXXMethod                          = CXCursor_CXXMethod;
CKCursorKind CKCursorKindNamespace                          = CXCursor_Namespace;
CKCursorKind CKCursorKindLinkageSpec                        = CXCursor_LinkageSpec;
CKCursorKind CKCursorKindConstructor                        = CXCursor_Constructor;
CKCursorKind CKCursorKindDestructor                         = CXCursor_Destructor;
CKCursorKind CKCursorKindConversionFunction                 = CXCursor_ConversionFunction;
CKCursorKind CKCursorKindTemplateTypeParameter              = CXCursor_TemplateTypeParameter;
CKCursorKind CKCursorKindNonTypeTemplateParameter           = CXCursor_NonTypeTemplateParameter;
CKCursorKind CKCursorKindTemplateTemplateParameter          = CXCursor_TemplateTemplateParameter;
CKCursorKind CKCursorKindFunctionTemplate                   = CXCursor_FunctionTemplate;
CKCursorKind CKCursorKindClassTemplate                      = CXCursor_ClassTemplate;
CKCursorKind CKCursorKindClassTemplatePartialSpecialization = CXCursor_ClassTemplatePartialSpecialization;
CKCursorKind CKCursorKindNamespaceAlias                     = CXCursor_NamespaceAlias;
CKCursorKind CKCursorKindUsingDirective                     = CXCursor_UsingDirective;
CKCursorKind CKCursorKindUsingDeclaration                   = CXCursor_UsingDeclaration;
CKCursorKind CKCursorKindTypeAliasDecl                      = CXCursor_TypeAliasDecl;
CKCursorKind CKCursorKindObjCSynthesizeDecl                 = CXCursor_ObjCSynthesizeDecl;
CKCursorKind CKCursorKindObjCDynamicDecl                    = CXCursor_ObjCDynamicDecl;
CKCursorKind CKCursorKindCXXAccessSpecifier                 = CXCursor_CXXAccessSpecifier;
CKCursorKind CKCursorKindFirstDecl                          = CXCursor_FirstDecl;
CKCursorKind CKCursorKindLastDecl                           = CXCursor_LastDecl;
CKCursorKind CKCursorKindFirstRef                           = CXCursor_FirstRef;
CKCursorKind CKCursorKindObjCSuperClassRef                  = CXCursor_ObjCSuperClassRef;
CKCursorKind CKCursorKindObjCProtocolRef                    = CXCursor_ObjCProtocolRef;
CKCursorKind CKCursorKindObjCClassRef                       = CXCursor_ObjCClassRef;
CKCursorKind CKCursorKindTypeRef                            = CXCursor_TypeRef;
CKCursorKind CKCursorKindCXXBaseSpecifier                   = CXCursor_CXXBaseSpecifier;
CKCursorKind CKCursorKindTemplateRef                        = CXCursor_TemplateRef;
CKCursorKind CKCursorKindNamespaceRef                       = CXCursor_NamespaceRef;
CKCursorKind CKCursorKindMemberRef                          = CXCursor_MemberRef;
CKCursorKind CKCursorKindLabelRef                           = CXCursor_LabelRef;
CKCursorKind CKCursorKindOverloadedDeclRef                  = CXCursor_OverloadedDeclRef;
CKCursorKind CKCursorKindVariableRef                        = CXCursor_VariableRef;
CKCursorKind CKCursorKindLastRef                            = CXCursor_LastRef;
CKCursorKind CKCursorKindFirstInvalid                       = CXCursor_FirstInvalid;
CKCursorKind CKCursorKindInvalidFile                        = CXCursor_InvalidFile;
CKCursorKind CKCursorKindNoDeclFound                        = CXCursor_NoDeclFound;
CKCursorKind CKCursorKindNotImplemented                     = CXCursor_NotImplemented;
CKCursorKind CKCursorKindInvalidCode                        = CXCursor_InvalidCode;
CKCursorKind CKCursorKindLastInvalid                        = CXCursor_LastInvalid;
CKCursorKind CKCursorKindFirstExpr                          = CXCursor_FirstExpr;
CKCursorKind CKCursorKindUnexposedExpr                      = CXCursor_UnexposedExpr;
CKCursorKind CKCursorKindDeclRefExpr                        = CXCursor_DeclRefExpr;
CKCursorKind CKCursorKindMemberRefExpr                      = CXCursor_MemberRefExpr;
CKCursorKind CKCursorKindCallExpr                           = CXCursor_CallExpr;
CKCursorKind CKCursorKindObjCMessageExpr                    = CXCursor_ObjCMessageExpr;
CKCursorKind CKCursorKindBlockExpr                          = CXCursor_BlockExpr;
CKCursorKind CKCursorKindIntegerLiteral                     = CXCursor_IntegerLiteral;
CKCursorKind CKCursorKindFloatingLiteral                    = CXCursor_FloatingLiteral;
CKCursorKind CKCursorKindImaginaryLiteral                   = CXCursor_ImaginaryLiteral;
CKCursorKind CKCursorKindStringLiteral                      = CXCursor_StringLiteral;
CKCursorKind CKCursorKindCharacterLiteral                   = CXCursor_CharacterLiteral;
CKCursorKind CKCursorKindParenExpr                          = CXCursor_ParenExpr;
CKCursorKind CKCursorKindUnaryOperator                      = CXCursor_UnaryOperator;
CKCursorKind CKCursorKindArraySubscriptExpr                 = CXCursor_ArraySubscriptExpr;
CKCursorKind CKCursorKindBinaryOperator                     = CXCursor_BinaryOperator;
CKCursorKind CKCursorKindCompoundAssignOperator             = CXCursor_CompoundAssignOperator;
CKCursorKind CKCursorKindConditionalOperator                = CXCursor_ConditionalOperator;
CKCursorKind CKCursorKindCStyleCastExpr                     = CXCursor_CStyleCastExpr;
CKCursorKind CKCursorKindCompoundLiteralExpr                = CXCursor_CompoundLiteralExpr;
CKCursorKind CKCursorKindInitListExpr                       = CXCursor_InitListExpr;
CKCursorKind CKCursorKindAddrLabelExpr                      = CXCursor_AddrLabelExpr;
CKCursorKind CKCursorKindStmtExpr                           = CXCursor_StmtExpr;
CKCursorKind CKCursorKindGenericSelectionExpr               = CXCursor_GenericSelectionExpr;
CKCursorKind CKCursorKindGNUNullExpr                        = CXCursor_GNUNullExpr;
CKCursorKind CKCursorKindCXXStaticCastExpr                  = CXCursor_CXXStaticCastExpr;
CKCursorKind CKCursorKindCXXDynamicCastExpr                 = CXCursor_CXXDynamicCastExpr;
CKCursorKind CKCursorKindCXXReinterpretCastExpr             = CXCursor_CXXReinterpretCastExpr;
CKCursorKind CKCursorKindCXXConstCastExpr                   = CXCursor_CXXConstCastExpr;
CKCursorKind CKCursorKindCXXFunctionalCastExpr              = CXCursor_CXXFunctionalCastExpr;
CKCursorKind CKCursorKindCXXTypeidExpr                      = CXCursor_CXXTypeidExpr;
CKCursorKind CKCursorKindCXXBoolLiteralExpr                 = CXCursor_CXXBoolLiteralExpr;
CKCursorKind CKCursorKindCXXNullPtrLiteralExpr              = CXCursor_CXXNullPtrLiteralExpr;
CKCursorKind CKCursorKindCXXThisExpr                        = CXCursor_CXXThisExpr;
CKCursorKind CKCursorKindCXXThrowExpr                       = CXCursor_CXXThrowExpr;
CKCursorKind CKCursorKindCXXNewExpr                         = CXCursor_CXXNewExpr;
CKCursorKind CKCursorKindCXXDeleteExpr                      = CXCursor_CXXDeleteExpr;
CKCursorKind CKCursorKindUnaryExpr                          = CXCursor_UnaryExpr;
CKCursorKind CKCursorKindObjCStringLiteral                  = CXCursor_ObjCStringLiteral;
CKCursorKind CKCursorKindObjCEncodeExpr                     = CXCursor_ObjCEncodeExpr;
CKCursorKind CKCursorKindObjCSelectorExpr                   = CXCursor_ObjCSelectorExpr;
CKCursorKind CKCursorKindObjCProtocolExpr                   = CXCursor_ObjCProtocolExpr;
CKCursorKind CKCursorKindObjCBridgedCastExpr                = CXCursor_ObjCBridgedCastExpr;
CKCursorKind CKCursorKindPackExpansionExpr                  = CXCursor_PackExpansionExpr;
CKCursorKind CKCursorKindSizeOfPackExpr                     = CXCursor_SizeOfPackExpr;
CKCursorKind CKCursorKindLambdaExpr                         = CXCursor_LambdaExpr;
CKCursorKind CKCursorKindObjCBoolLiteralExpr                = CXCursor_ObjCBoolLiteralExpr;
CKCursorKind CKCursorKindLastExpr                           = CXCursor_LastExpr;
CKCursorKind CKCursorKindFirstStmt                          = CXCursor_FirstStmt;
CKCursorKind CKCursorKindUnexposedStmt                      = CXCursor_UnexposedStmt;
CKCursorKind CKCursorKindLabelStmt                          = CXCursor_LabelStmt;
CKCursorKind CKCursorKindCompoundStmt                       = CXCursor_CompoundStmt;
CKCursorKind CKCursorKindCaseStmt                           = CXCursor_CaseStmt;
CKCursorKind CKCursorKindDefaultStmt                        = CXCursor_DefaultStmt;
CKCursorKind CKCursorKindIfStmt                             = CXCursor_IfStmt;
CKCursorKind CKCursorKindSwitchStmt                         = CXCursor_SwitchStmt;
CKCursorKind CKCursorKindWhileStmt                          = CXCursor_WhileStmt;
CKCursorKind CKCursorKindDoStmt                             = CXCursor_DoStmt;
CKCursorKind CKCursorKindForStmt                            = CXCursor_ForStmt;
CKCursorKind CKCursorKindGotoStmt                           = CXCursor_GotoStmt;
CKCursorKind CKCursorKindIndirectGotoStmt                   = CXCursor_IndirectGotoStmt;
CKCursorKind CKCursorKindContinueStmt                       = CXCursor_ContinueStmt;
CKCursorKind CKCursorKindBreakStmt                          = CXCursor_BreakStmt;
CKCursorKind CKCursorKindReturnStmt                         = CXCursor_ReturnStmt;
CKCursorKind CKCursorKindAsmStmt                            = CXCursor_AsmStmt;
CKCursorKind CKCursorKindObjCAtTryStmt                      = CXCursor_ObjCAtTryStmt;
CKCursorKind CKCursorKindObjCAtCatchStmt                    = CXCursor_ObjCAtCatchStmt;
CKCursorKind CKCursorKindObjCAtFinallyStmt                  = CXCursor_ObjCAtFinallyStmt;
CKCursorKind CKCursorKindObjCAtThrowStmt                    = CXCursor_ObjCAtThrowStmt;
CKCursorKind CKCursorKindObjCAtSynchronizedStmt             = CXCursor_ObjCAtSynchronizedStmt;
CKCursorKind CKCursorKindObjCAutoreleasePoolStmt            = CXCursor_ObjCAutoreleasePoolStmt;
CKCursorKind CKCursorKindObjCForCollectionStmt              = CXCursor_ObjCForCollectionStmt;
CKCursorKind CKCursorKindCXXCatchStmt                       = CXCursor_CXXCatchStmt;
CKCursorKind CKCursorKindCXXTryStmt                         = CXCursor_CXXTryStmt;
CKCursorKind CKCursorKindCXXForRangeStmt                    = CXCursor_CXXForRangeStmt;
CKCursorKind CKCursorKindSEHTryStmt                         = CXCursor_SEHTryStmt;
CKCursorKind CKCursorKindSEHExceptStmt                      = CXCursor_SEHExceptStmt;
CKCursorKind CKCursorKindSEHFinallyStmt                     = CXCursor_SEHFinallyStmt;
CKCursorKind CKCursorKindMSAsmStmt                          = CXCursor_MSAsmStmt;
CKCursorKind CKCursorKindNullStmt                           = CXCursor_NullStmt;
CKCursorKind CKCursorKindDeclStmt                           = CXCursor_DeclStmt;
CKCursorKind CKCursorKindLastStmt                           = CXCursor_LastStmt;
CKCursorKind CKCursorKindTranslationUnit                    = CXCursor_TranslationUnit;
CKCursorKind CKCursorKindFirstAttr                          = CXCursor_FirstAttr;
CKCursorKind CKCursorKindUnexposedAttr                      = CXCursor_UnexposedAttr;
CKCursorKind CKCursorKindIBActionAttr                       = CXCursor_IBActionAttr;
CKCursorKind CKCursorKindIBOutletAttr                       = CXCursor_IBOutletAttr;
CKCursorKind CKCursorKindIBOutletCollectionAttr             = CXCursor_IBOutletCollectionAttr;
CKCursorKind CKCursorKindCXXFinalAttr                       = CXCursor_CXXFinalAttr;
CKCursorKind CKCursorKindCXXOverrideAttr                    = CXCursor_CXXOverrideAttr;
CKCursorKind CKCursorKindAnnotateAttr                       = CXCursor_AnnotateAttr;
CKCursorKind CKCursorKindAsmLabelAttr                       = CXCursor_AsmLabelAttr;
CKCursorKind CKCursorKindLastAttr                           = CXCursor_LastAttr;
CKCursorKind CKCursorKindPreprocessingDirective             = CXCursor_PreprocessingDirective;
CKCursorKind CKCursorKindMacroDefinition                    = CXCursor_MacroDefinition;
CKCursorKind CKCursorKindMacroExpansion                     = CXCursor_MacroExpansion;
CKCursorKind CKCursorKindMacroInstantiation                 = CXCursor_MacroInstantiation;
CKCursorKind CKCursorKindInclusionDirective                 = CXCursor_InclusionDirective;
CKCursorKind CKCursorKindFirstPreprocessing                 = CXCursor_FirstPreprocessing;
CKCursorKind CKCursorKindLastPreprocessing                  = CXCursor_LastPreprocessing;


@interface CKCursor() {
    CKCursor    *_referenced;
    CKCursor    *_definition;
    CKCursor    *_canonical;
    CKCursor    *_lexicalParent;
    CKCursor    *_semanticParent;
}

@end

@implementation CKCursor

#pragma mark - Initialize
- (id)initWithCXCursor:(CXCursor)cursor {

    CXString            displayName;
    CXString            kindSpelling;
    CXString            spelling;
    CXSourceLocation    location;
    self = [self init];

    if (self) {
        
        if(clang_Cursor_isNull(cursor)) {
            return nil;
        }
        
        _cxCursorPointer = calloc(sizeof(CXCursor), 1);
        
        memcpy(_cxCursorPointer, &cursor, sizeof(CXCursor));
        
        _kind           = clang_getCursorKind(cursor);
        displayName     = clang_getCursorDisplayName(cursor);
        kindSpelling    = clang_getCursorKindSpelling((enum CXCursorKind)_kind);
        location        = clang_getCursorLocation(cursor);
        spelling        = clang_getCursorSpelling(cursor);

        
        _displayName    = [[NSString alloc] initWithCString: clang_getCString(displayName) encoding: NSUTF8StringEncoding];
        _kindSpelling   = [[NSString alloc] initWithCString: clang_getCString(kindSpelling) encoding: NSUTF8StringEncoding];
        _spelling       = [[NSString alloc] initWithCString: clang_getCString(spelling) encoding: NSUTF8StringEncoding];
        _location       = [[CKSourceLocation alloc] initWithCXSourceLocationValue:[NSValue value:&location withObjCType:@encode(CXSourceLocation)]];
        
        if(clang_isCursorDefinition(cursor)) {
            _isDefinition = YES;
        }
        
        [self definition];
        [self referenced];
        
        if(clang_isDeclaration(    (enum CXCursorKind)_kind)) { _isDeclaration     = YES; }
        if(clang_isReference(      (enum CXCursorKind)_kind)) { _isReference       = YES; }
        if(clang_isPreprocessing(  (enum CXCursorKind)_kind)) { _isPreprocessing   = YES; }
        if(clang_isExpression(     (enum CXCursorKind)_kind)) { _isExpression      = YES; }
        if(clang_isAttribute(      (enum CXCursorKind)_kind)) { _isAttribute       = YES; }
        if(clang_isInvalid(        (enum CXCursorKind)_kind)) { _isInvalid         = YES; }
        if(clang_isStatement(      (enum CXCursorKind)_kind)) { _isStatement       = YES; }
        if(clang_isTranslationUnit((enum CXCursorKind)_kind)) { _isTranslationUnit = YES; }
        if(clang_isUnexposed(      (enum CXCursorKind)_kind)) { _isUnexposed       = YES; }
        
        clang_disposeString(kindSpelling);
        clang_disposeString(displayName);
        clang_disposeString(spelling);
    }
    
    return self;
}
+ (id)cursorWithLocation:(CKSourceLocation *)location translationUnit:(CKTranslationUnit *)translationUnit {
    return [[CKCursor alloc] initWithLocation:location translationUnit:translationUnit];
}

- (id) initWithLocation:(CKSourceLocation *)location translationUnit:(CKTranslationUnit *)translationUnit {
    CXSourceLocation cxSourceLocation;
    [[location cxLocationValue] getValue:&cxSourceLocation];
    CXCursor cursor = clang_getCursor( translationUnit.cxTranslationUnit, cxSourceLocation);
    return [self initWithCXCursor: cursor];
    
}



- (CKCursor *)referenced {
    CXCursor cursor;
    CXCursor referenced;
    
    if(!_referenced && _cxCursorPointer != NULL && !_isDefinition) {
        memcpy( &cursor, _cxCursorPointer, sizeof( CXCursor ) );
        
        referenced  = clang_getCursorReferenced(cursor);
        
        if( clang_equalCursors( cursor, referenced ) == 0 ){
            _referenced = [[[CKCursor class] alloc] initWithCXCursor:referenced];
        }
    }
    
    return _referenced;
}

- (CKCursor *)definition {
    CXCursor cursor;
    CXCursor definition;
    
    if( !_definition && _cxCursorPointer != NULL && !_isDefinition){
        memcpy(&cursor, _cxCursorPointer, sizeof(CXCursor));
        
        definition  = clang_getCursorDefinition(cursor);
        
        if(clang_Cursor_isNull(definition) == 0)
            _definition = [[[CKCursor class] alloc] initWithCXCursor:definition];
    }
    
    return _definition;
}

- (CKCursor *)canonical {
    CXCursor cursor;
    CXCursor canonical;
    
    if(!_canonical && _cxCursorPointer != NULL) {
        memcpy(&cursor, _cxCursorPointer, sizeof(CXCursor));
        
        canonical = clang_getCanonicalCursor(cursor);
        _canonical = [[[CKCursor class] alloc] initWithCXCursor:canonical];
    }
    
    return _canonical;
}

- (CKCursor *)lexicalParent {
    CXCursor cursor;
    CXCursor lexicalParent;
    
    if(!_referenced && _cxCursorPointer != NULL) {
        memcpy(&cursor, _cxCursorPointer, sizeof(CXCursor));
        
        lexicalParent = clang_getCursorReferenced(cursor);
        _lexicalParent = [[[CKCursor class] alloc] initWithCXCursor:lexicalParent];
    }
    
    return _referenced;
}

- (CKCursor *)semanticParent {
    CXCursor cursor;
    CXCursor semanticParent;
    
    if(!_semanticParent && _cxCursorPointer != NULL) {
        memcpy(&cursor, _cxCursorPointer, sizeof(CXCursor));
        
        semanticParent  = clang_getCursorReferenced( cursor );
        _semanticParent = [[[ CKCursor class] alloc] initWithCXCursor:semanticParent];
    }
    
    return _semanticParent;
}

- (NSString *)description {
    
    NSString * description;
    
    description = [super description];
    
    description = [description stringByAppendingFormat:@"\n   displayName: '%@'\n", [self displayName]];
    
    description = [description stringByAppendingFormat:@"   kindSpelling: %@\n", [self kindSpelling]];
    description = [description stringByAppendingFormat:@"   spelling: %@\n", [self spelling]];

    description = [description stringByAppendingFormat:@"   kind: %@\n", [self kindString]];
    description = [description stringByAppendingFormat:@"   \n"];
    
    description = [description stringByAppendingFormat:@"   isDefinition: %@\n", [NSString stringFromBOOL:self.isDefinition]];
    description = [description stringByAppendingFormat:@"   isDeclaration: %@\n", [NSString stringFromBOOL:self.isDeclaration]];
    description = [description stringByAppendingFormat:@"   isReference: %@\n", [NSString stringFromBOOL:self.isReference]];
    description = [description stringByAppendingFormat:@"   isPreprocessing: %@\n", [NSString stringFromBOOL:self.isPreprocessing]];
    description = [description stringByAppendingFormat:@"   isExpression: %@\n", [NSString stringFromBOOL:self.isExpression]];
    description = [description stringByAppendingFormat:@"   isAttribute: %@\n", [NSString stringFromBOOL:self.isAttribute]];
    description = [description stringByAppendingFormat:@"   isInvalid: %@\n", [NSString stringFromBOOL:self.isInvalid]];
    description = [description stringByAppendingFormat:@"   isStatement: %@\n", [NSString stringFromBOOL:self.isStatement]];
    description = [description stringByAppendingFormat:@"   isTranslationUnit: %@\n", [NSString stringFromBOOL:self.isTranslationUnit]];
    description = [description stringByAppendingFormat:@"   isUnexposed: %@\n", [NSString stringFromBOOL:self.isUnexposed]];

    description = [description stringByAppendingFormat:@"   \n"];

    if (NO) {
        //description = [description stringByAppendingFormat:@"definition: {%@}\n", self.definition];
        //description = [description stringByAppendingFormat:@"semanticParent: {%@}\n", self.semanticParent];
        //description = [description stringByAppendingFormat:@"lexicalParent: {%@}\n", self.lexicalParent];
        //description = [description stringByAppendingFormat:@"canonical: {%@}\n", self.canonical];
        //description = [description stringByAppendingFormat:@"referenced: {%@}\n", self.referenced];
    }
    
    description = [description stringByAppendingFormat:@"   location: {%@}\n", self.location];

    return description;
}



- (NSString *) kindString {
    
    if (self.kind == CKCursorKindUnexposedDecl) { return @"CKCursorKindUnexposedDecl"; }
    if (self.kind == CKCursorKindStructDecl) { return @"CKCursorKindStructDecl"; }
    if (self.kind == CKCursorKindUnionDecl) { return @"CKCursorKindUnionDecl"; }
    if (self.kind == CKCursorKindClassDecl) { return @"CKCursorKindClassDecl"; }
    if (self.kind == CKCursorKindEnumDecl) { return @"CKCursorKindEnumDecl"; }
    if (self.kind == CKCursorKindFieldDecl) { return @"CKCursorKindFieldDecl"; }
    if (self.kind == CKCursorKindEnumConstantDecl) { return @"CKCursorKindEnumConstantDecl"; }
    if (self.kind == CKCursorKindFunctionDecl) { return @"CKCursorKindFunctionDecl"; }
    if (self.kind == CKCursorKindVarDecl) { return @"CKCursorKindVarDecl"; }
    if (self.kind == CKCursorKindParmDecl) { return @"CKCursorKindParmDecl"; }
    if (self.kind == CKCursorKindObjCInterfaceDecl) { return @"CKCursorKindObjCInterfaceDecl"; }
    if (self.kind == CKCursorKindObjCCategoryDecl) { return @"CKCursorKindObjCCategoryDecl"; }
    if (self.kind == CKCursorKindObjCProtocolDecl) { return @"CKCursorKindObjCProtocolDecl"; }
    if (self.kind == CKCursorKindObjCPropertyDecl) { return @"CKCursorKindObjCPropertyDecl"; }
    if (self.kind == CKCursorKindObjCIvarDecl) { return @"CKCursorKindObjCIvarDecl"; }
    if (self.kind == CKCursorKindObjCInstanceMethodDecl) { return @"CKCursorKindObjCInstanceMethodDecl"; }
    if (self.kind == CKCursorKindObjCClassMethodDecl) { return @"CKCursorKindObjCClassMethodDecl"; }
    if (self.kind == CKCursorKindObjCImplementationDecl) { return @"CKCursorKindObjCImplementationDecl"; }
    if (self.kind == CKCursorKindObjCCategoryImplDecl) { return @"CKCursorKindObjCCategoryImplDecl"; }
    if (self.kind == CKCursorKindTypedefDecl) { return @"CKCursorKindTypedefDecl"; }
    if (self.kind == CKCursorKindCXXMethod) { return @"CKCursorKindCXXMethod"; }
    if (self.kind == CKCursorKindNamespace) { return @"CKCursorKindNamespace"; }
    if (self.kind == CKCursorKindLinkageSpec) { return @"CKCursorKindLinkageSpec"; }
    if (self.kind == CKCursorKindConstructor) { return @"CKCursorKindConstructor"; }
    if (self.kind == CKCursorKindDestructor) { return @"CKCursorKindDestructor"; }
    if (self.kind == CKCursorKindConversionFunction) { return @"CKCursorKindConversionFunction"; }
    if (self.kind == CKCursorKindTemplateTypeParameter) { return @"CKCursorKindTemplateTypeParameter"; }
    if (self.kind == CKCursorKindNonTypeTemplateParameter) { return @"CKCursorKindNonTypeTemplateParameter"; }
    if (self.kind == CKCursorKindTemplateTemplateParameter) { return @"CKCursorKindTemplateTemplateParameter"; }
    if (self.kind == CKCursorKindFunctionTemplate) { return @"CKCursorKindFunctionTemplate"; }
    if (self.kind == CKCursorKindClassTemplate) { return @"CKCursorKindClassTemplate"; }
    if (self.kind == CKCursorKindClassTemplatePartialSpecialization) { return @"CKCursorKindClassTemplatePartialSpecialization"; }
    if (self.kind == CKCursorKindNamespaceAlias) { return @"CKCursorKindNamespaceAlias"; }
    if (self.kind == CKCursorKindUsingDirective) { return @"CKCursorKindUsingDirective"; }
    if (self.kind == CKCursorKindUsingDeclaration) { return @"CKCursorKindUsingDeclaration"; }
    if (self.kind == CKCursorKindTypeAliasDecl) { return @"CKCursorKindTypeAliasDecl"; }
    if (self.kind == CKCursorKindObjCSynthesizeDecl) { return @"CKCursorKindObjCSynthesizeDecl"; }
    if (self.kind == CKCursorKindObjCDynamicDecl) { return @"CKCursorKindObjCDynamicDecl"; }
    if (self.kind == CKCursorKindCXXAccessSpecifier) { return @"CKCursorKindCXXAccessSpecifier"; }
    if (self.kind == CKCursorKindFirstDecl) { return @"CKCursorKindFirstDecl"; }
    if (self.kind == CKCursorKindLastDecl) { return @"CKCursorKindLastDecl"; }
    if (self.kind == CKCursorKindFirstRef) { return @"CKCursorKindFirstRef"; }
    if (self.kind == CKCursorKindObjCSuperClassRef) { return @"CKCursorKindObjCSuperClassRef"; }
    if (self.kind == CKCursorKindObjCProtocolRef) { return @"CKCursorKindObjCProtocolRef"; }
    if (self.kind == CKCursorKindObjCClassRef) { return @"CKCursorKindObjCClassRef"; }
    if (self.kind == CKCursorKindTypeRef) { return @"CKCursorKindTypeRef"; }
    if (self.kind == CKCursorKindCXXBaseSpecifier) { return @"CKCursorKindCXXBaseSpecifier"; }
    if (self.kind == CKCursorKindTemplateRef) { return @"CKCursorKindTemplateRef"; }
    if (self.kind == CKCursorKindNamespaceRef) { return @"CKCursorKindNamespaceRef"; }
    if (self.kind == CKCursorKindMemberRef) { return @"CKCursorKindMemberRef"; }
    if (self.kind == CKCursorKindLabelRef) { return @"CKCursorKindLabelRef"; }
    if (self.kind == CKCursorKindOverloadedDeclRef) { return @"CKCursorKindOverloadedDeclRef"; }
    if (self.kind == CKCursorKindVariableRef) { return @"CKCursorKindVariableRef"; }
    if (self.kind == CKCursorKindLastRef) { return @"CKCursorKindLastRef"; }
    if (self.kind == CKCursorKindFirstInvalid) { return @"CKCursorKindFirstInvalid"; }
    if (self.kind == CKCursorKindInvalidFile) { return @"CKCursorKindInvalidFile"; }
    if (self.kind == CKCursorKindNoDeclFound) { return @"CKCursorKindNoDeclFound"; }
    if (self.kind == CKCursorKindNotImplemented) { return @"CKCursorKindNotImplemented"; }
    if (self.kind == CKCursorKindInvalidCode) { return @"CKCursorKindInvalidCode"; }
    if (self.kind == CKCursorKindLastInvalid) { return @"CKCursorKindLastInvalid"; }
    if (self.kind == CKCursorKindFirstExpr) { return @"CKCursorKindFirstExpr"; }
    if (self.kind == CKCursorKindUnexposedExpr) { return @"CKCursorKindUnexposedExpr"; }
    if (self.kind == CKCursorKindDeclRefExpr) { return @"CKCursorKindDeclRefExpr"; }
    if (self.kind == CKCursorKindMemberRefExpr) { return @"CKCursorKindMemberRefExpr"; }
    if (self.kind == CKCursorKindCallExpr) { return @"CKCursorKindCallExpr"; }
    if (self.kind == CKCursorKindObjCMessageExpr) { return @"CKCursorKindObjCMessageExpr"; }
    if (self.kind == CKCursorKindBlockExpr) { return @"CKCursorKindBlockExpr"; }
    if (self.kind == CKCursorKindIntegerLiteral) { return @"CKCursorKindIntegerLiteral"; }
    if (self.kind == CKCursorKindFloatingLiteral) { return @"CKCursorKindFloatingLiteral"; }
    if (self.kind == CKCursorKindImaginaryLiteral) { return @"CKCursorKindImaginaryLiteral"; }
    if (self.kind == CKCursorKindStringLiteral) { return @"CKCursorKindStringLiteral"; }
    if (self.kind == CKCursorKindCharacterLiteral) { return @"CKCursorKindCharacterLiteral"; }
    if (self.kind == CKCursorKindParenExpr) { return @"CKCursorKindParenExpr"; }
    if (self.kind == CKCursorKindUnaryOperator) { return @"CKCursorKindUnaryOperator"; }
    if (self.kind == CKCursorKindArraySubscriptExpr) { return @"CKCursorKindArraySubscriptExpr"; }
    if (self.kind == CKCursorKindBinaryOperator) { return @"CKCursorKindBinaryOperator"; }
    if (self.kind == CKCursorKindCompoundAssignOperator) { return @"CKCursorKindCompoundAssignOperator"; }
    if (self.kind == CKCursorKindConditionalOperator) { return @"CKCursorKindConditionalOperator"; }
    if (self.kind == CKCursorKindCStyleCastExpr) { return @"CKCursorKindCStyleCastExpr"; }
    if (self.kind == CKCursorKindCompoundLiteralExpr) { return @"CKCursorKindCompoundLiteralExpr"; }
    if (self.kind == CKCursorKindInitListExpr) { return @"CKCursorKindInitListExpr"; }
    if (self.kind == CKCursorKindAddrLabelExpr) { return @"CKCursorKindAddrLabelExpr"; }
    if (self.kind == CKCursorKindStmtExpr) { return @"CKCursorKindStmtExpr"; }
    if (self.kind == CKCursorKindGenericSelectionExpr) { return @"CKCursorKindGenericSelectionExpr"; }
    if (self.kind == CKCursorKindGNUNullExpr) { return @"CKCursorKindGNUNullExpr"; }
    if (self.kind == CKCursorKindCXXStaticCastExpr) { return @"CKCursorKindCXXStaticCastExpr"; }
    if (self.kind == CKCursorKindCXXDynamicCastExpr) { return @"CKCursorKindCXXDynamicCastExpr"; }
    if (self.kind == CKCursorKindCXXReinterpretCastExpr) { return @"CKCursorKindCXXReinterpretCastExpr"; }
    if (self.kind == CKCursorKindCXXConstCastExpr) { return @"CKCursorKindCXXConstCastExpr"; }
    if (self.kind == CKCursorKindCXXFunctionalCastExpr) { return @"CKCursorKindCXXFunctionalCastExpr"; }
    if (self.kind == CKCursorKindCXXTypeidExpr) { return @"CKCursorKindCXXTypeidExpr"; }
    if (self.kind == CKCursorKindCXXBoolLiteralExpr) { return @"CKCursorKindCXXBoolLiteralExpr"; }
    if (self.kind == CKCursorKindCXXNullPtrLiteralExpr) { return @"CKCursorKindCXXNullPtrLiteralExpr"; }
    if (self.kind == CKCursorKindCXXThisExpr) { return @"CKCursorKindCXXThisExpr"; }
    if (self.kind == CKCursorKindCXXThrowExpr) { return @"CKCursorKindCXXThrowExpr"; }
    if (self.kind == CKCursorKindCXXNewExpr) { return @"CKCursorKindCXXNewExpr"; }
    if (self.kind == CKCursorKindCXXDeleteExpr) { return @"CKCursorKindCXXDeleteExpr"; }
    if (self.kind == CKCursorKindUnaryExpr) { return @"CKCursorKindUnaryExpr"; }
    if (self.kind == CKCursorKindObjCStringLiteral) { return @"CKCursorKindObjCStringLiteral"; }
    if (self.kind == CKCursorKindObjCEncodeExpr) { return @"CKCursorKindObjCEncodeExpr"; }
    if (self.kind == CKCursorKindObjCSelectorExpr) { return @"CKCursorKindObjCSelectorExpr"; }
    if (self.kind == CKCursorKindObjCProtocolExpr) { return @"CKCursorKindObjCProtocolExpr"; }
    if (self.kind == CKCursorKindObjCBridgedCastExpr) { return @"CKCursorKindObjCBridgedCastExpr"; }
    if (self.kind == CKCursorKindPackExpansionExpr) { return @"CKCursorKindPackExpansionExpr"; }
    if (self.kind == CKCursorKindSizeOfPackExpr) { return @"CKCursorKindSizeOfPackExpr"; }
    if (self.kind == CKCursorKindLambdaExpr) { return @"CKCursorKindLambdaExpr"; }
    if (self.kind == CKCursorKindObjCBoolLiteralExpr) { return @"CKCursorKindObjCBoolLiteralExpr"; }
    if (self.kind == CKCursorKindLastExpr) { return @"CKCursorKindLastExpr"; }
    if (self.kind == CKCursorKindFirstStmt) { return @"CKCursorKindFirstStmt"; }
    if (self.kind == CKCursorKindUnexposedStmt) { return @"CKCursorKindUnexposedStmt"; }
    if (self.kind == CKCursorKindLabelStmt) { return @"CKCursorKindLabelStmt"; }
    if (self.kind == CKCursorKindCompoundStmt) { return @"CKCursorKindCompoundStmt"; }
    if (self.kind == CKCursorKindCaseStmt) { return @"CKCursorKindCaseStmt"; }
    if (self.kind == CKCursorKindDefaultStmt) { return @"CKCursorKindDefaultStmt"; }
    if (self.kind == CKCursorKindIfStmt) { return @"CKCursorKindIfStmt"; }
    if (self.kind == CKCursorKindSwitchStmt) { return @"CKCursorKindSwitchStmt"; }
    if (self.kind == CKCursorKindWhileStmt) { return @"CKCursorKindWhileStmt"; }
    if (self.kind == CKCursorKindDoStmt) { return @"CKCursorKindDoStmt"; }
    if (self.kind == CKCursorKindForStmt) { return @"CKCursorKindForStmt"; }
    if (self.kind == CKCursorKindGotoStmt) { return @"CKCursorKindGotoStmt"; }
    if (self.kind == CKCursorKindIndirectGotoStmt) { return @"CKCursorKindIndirectGotoStmt"; }
    if (self.kind == CKCursorKindContinueStmt) { return @"CKCursorKindContinueStmt"; }
    if (self.kind == CKCursorKindBreakStmt) { return @"CKCursorKindBreakStmt"; }
    if (self.kind == CKCursorKindReturnStmt) { return @"CKCursorKindReturnStmt"; }
    if (self.kind == CKCursorKindAsmStmt) { return @"CKCursorKindAsmStmt"; }
    if (self.kind == CKCursorKindObjCAtTryStmt) { return @"CKCursorKindObjCAtTryStmt"; }
    if (self.kind == CKCursorKindObjCAtCatchStmt) { return @"CKCursorKindObjCAtCatchStmt"; }
    if (self.kind == CKCursorKindObjCAtFinallyStmt) { return @"CKCursorKindObjCAtFinallyStmt"; }
    if (self.kind == CKCursorKindObjCAtThrowStmt) { return @"CKCursorKindObjCAtThrowStmt"; }
    if (self.kind == CKCursorKindObjCAtSynchronizedStmt) { return @"CKCursorKindObjCAtSynchronizedStmt"; }
    if (self.kind == CKCursorKindObjCAutoreleasePoolStmt) { return @"CKCursorKindObjCAutoreleasePoolStmt"; }
    if (self.kind == CKCursorKindObjCForCollectionStmt) { return @"CKCursorKindObjCForCollectionStmt"; }
    if (self.kind == CKCursorKindCXXCatchStmt) { return @"CKCursorKindCXXCatchStmt"; }
    if (self.kind == CKCursorKindCXXTryStmt) { return @"CKCursorKindCXXTryStmt"; }
    if (self.kind == CKCursorKindCXXForRangeStmt) { return @"CKCursorKindCXXForRangeStmt"; }
    if (self.kind == CKCursorKindSEHTryStmt) { return @"CKCursorKindSEHTryStmt"; }
    if (self.kind == CKCursorKindSEHExceptStmt) { return @"CKCursorKindSEHExceptStmt"; }
    if (self.kind == CKCursorKindSEHFinallyStmt) { return @"CKCursorKindSEHFinallyStmt"; }
    if (self.kind == CKCursorKindMSAsmStmt) { return @"CKCursorKindMSAsmStmt"; }
    if (self.kind == CKCursorKindNullStmt) { return @"CKCursorKindNullStmt"; }
    if (self.kind == CKCursorKindDeclStmt) { return @"CKCursorKindDeclStmt"; }
    if (self.kind == CKCursorKindLastStmt) { return @"CKCursorKindLastStmt"; }
    if (self.kind == CKCursorKindTranslationUnit) { return @"CKCursorKindTranslationUnit"; }
    if (self.kind == CKCursorKindFirstAttr) { return @"CKCursorKindFirstAttr"; }
    if (self.kind == CKCursorKindUnexposedAttr) { return @"CKCursorKindUnexposedAttr"; }
    if (self.kind == CKCursorKindIBActionAttr) { return @"CKCursorKindIBActionAttr"; }
    if (self.kind == CKCursorKindIBOutletAttr) { return @"CKCursorKindIBOutletAttr"; }
    if (self.kind == CKCursorKindIBOutletCollectionAttr) { return @"CKCursorKindIBOutletCollectionAttr"; }
    if (self.kind == CKCursorKindCXXFinalAttr) { return @"CKCursorKindCXXFinalAttr"; }
    if (self.kind == CKCursorKindCXXOverrideAttr) { return @"CKCursorKindCXXOverrideAttr"; }
    if (self.kind == CKCursorKindAnnotateAttr) { return @"CKCursorKindAnnotateAttr"; }
    if (self.kind == CKCursorKindAsmLabelAttr) { return @"CKCursorKindAsmLabelAttr"; }
    if (self.kind == CKCursorKindLastAttr) { return @"CKCursorKindLastAttr"; }
    if (self.kind == CKCursorKindPreprocessingDirective) { return @"CKCursorKindPreprocessingDirective"; }
    if (self.kind == CKCursorKindMacroDefinition) { return @"CKCursorKindMacroDefinition"; }
    if (self.kind == CKCursorKindMacroExpansion) { return @"CKCursorKindMacroExpansion"; }
    if (self.kind == CKCursorKindMacroInstantiation) { return @"CKCursorKindMacroInstantiation"; }
    if (self.kind == CKCursorKindInclusionDirective) { return @"CKCursorKindInclusionDirective"; }
    if (self.kind == CKCursorKindFirstPreprocessing) { return @"CKCursorKindFirstPreprocessing"; }
    if (self.kind == CKCursorKindLastPreprocessing) { return @"CKCursorKindLastPreprocessing"; }
    
    
    return [NSString stringWithFormat:@"Unknown description for kind:%lu", self.kind];
}
    
- (void)dealloc {
    free(_cxCursorPointer);
}


@end
