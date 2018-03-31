//
//  QCCFamilyHighlighter.m
//  Qapular Code Composer
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2015 Qapular. All rights reserved.
//

#import "QCCFamilyHighlighter.h"
#import <ClangKit/ClangKit.h>

#import "QCCodeStorage.h"
#import "QCCThemaManager.h"



@implementation QCCFamilyHighlighter

- (BOOL) highlighteByTokenArray:(NSArray *) tokens {
    [_codeStorage removeAllMarkers];
    
    for (CKToken *token in tokens) {
        NSDictionary *attributes  = [self attributesForToken:token cursor:token.cursor];
        
        if (attributes) {
            /*
            NSLayoutManager *manager  = [[_codeStorage layoutManagers] firstObject];
//            [manager removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:NSMakeRange(0, _codeStorage.string.length)];
            [manager addTemporaryAttributes:@{NSBackgroundColorAttributeName : [NSColor orangeColor]} forCharacterRange:token.range];
            */
            
            [_codeStorage setTemporaryAttributes:attributes forCharacterRange:token.range];
        }
        
        else
            NSLog(@"Unknown attribute for token %@", token);
    }

    return YES;
}



- (NSDictionary *) attributesForToken:(CKToken *) token cursor:(CKCursor *) cursor {
    
    CKTokenKind tokenKind = token.kind;
    CKCursorKind cursorKind = cursor.kind;
    
    /*
    if (cursor.definition)
        NSLog(@"definition: %@", cursor.definition);

    
    if (cursor.referenced)
        NSLog(@"referenced: %@", cursor.referenced);
     */
    
    if (tokenKind == CKTokenKindPunctuation) {
        if (cursorKind == CKCursorKindObjCImplementationDecl)
            return [self attributesForString];
        
        if (cursorKind == CKCursorKindInclusionDirective) {
            if ([[self includesKeyWords] containsObject:token.spelling])
                return [self attributesForPreprocessor];
            else
                return [self attributesForString];
        }
        
        
        return [self attributesForPlain];
    }
    
    
    if (tokenKind == CKTokenKindKeyword)
        return [self attributesForKeyword];
    

    if (tokenKind == CKTokenKindIdentifier) {
    
        if (cursorKind == CKCursorKindVarDecl || cursorKind == CKCursorKindObjCIvarDecl)
            return [self attributesForIdentifierVariable];
        
        if (cursorKind == CKCursorKindLastExpr)
            return [self attributesForIdentifierVariable];
        
        if (cursorKind == CKCursorKindFunctionDecl)
            return [self attributesForIdentifierFunction];
        
        if (cursorKind == CKCursorKindTypeRef)
            return [self attributesForIdentifierTypeRef];
        
        if (cursorKind == CKCursorKindObjCClassRef || cursorKind == CKCursorKindClassDecl)
            return [self attributesForIdentifierClassRef];
        
        if (cursorKind == CKCursorKindInclusionDirective){
            if ([[self includesKeyWords] containsObject:token.spelling])
                return [self attributesForPreprocessor];
            else
                return [self attributesForString];
        }
        
        if (cursorKind == CKCursorKindUnexposedDecl)
            return [self attributesForIdentifierTypeSystem];
        
        if (cursorKind == CKCursorKindDeclStmt)
            return [self attributesForIdentifierPlain];
        
        if (cursorKind == CKCursorKindForStmt)
            return [self attributesForIdentifierFunctionSystem];
        
        if (cursorKind == CKCursorKindObjCMessageExpr)
            return [self attributesForIdentifierFunction];
        
        if (cursorKind == CKCursorKindObjCMessageExpr)
            return [self attributesForIdentifierVariable];
        
        if (cursorKind == CKCursorKindMacroDefinition)
            return [self attributesForIdentifierMacro];
        
        if (cursorKind == CKCursorKindMacroExpansion)
            return [self attributesForIdentifierMacroSystem];
        
        if (cursorKind == CKCursorKindObjCForCollectionStmt)
            return [self attributesForIdentifierPlain];


        
        // Default Identifier
        
        if (cursorKind == CKCursorKindObjCCategoryDecl)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindCompoundStmt)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindObjCImplementationDecl)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindObjCInstanceMethodDecl)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindParmDecl)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindDeclRefExpr)
            return [self attributesForIdentifier];
        
        if (cursorKind == CKCursorKindNoDeclFound)
            return [self attributesForIdentifier];
        
        
        //return [self attributesForIdentifier];
    }
    

    if (tokenKind == CKTokenKindLiteral) {
    
        if (cursorKind == CKCursorKindInclusionDirective){
            if ([[self includesKeyWords] containsObject:token.spelling])
                return [self attributesForPreprocessor];
            else
                return [self attributesForString];
        }
        
        
        if (cursorKind == CKCursorKindNoDeclFound)
            return [self attributesForString];
        
        if (cursorKind == CKCursorKindCompoundStmt)
            return [self attributesForString];

        if (cursorKind == CKCursorKindObjCImplementationDecl)
            return [self attributesForString];
        
        if (cursorKind == CKCursorKindStringLiteral)
            return [self attributesForString];
        
        
        if (cursorKind == CKCursorKindDeclStmt)
            return [self attributesForPlain];
    
        if (cursorKind == CKCursorKindIntegerLiteral)
            return [self attributesForNumber];
        
        if (cursorKind == CKCursorKindMacroDefinition)
            return [self attributesForIdentifierMacro];
    }
    

    if (tokenKind == CKTokenKindComment)
        return [self attributesForComment];
    
    return nil;
}

#pragma mark - Attribute
- (NSDictionary *) attributesForAttribute {
    return nil;
}


#pragma mark - Comment
- (NSDictionary *) attributesForComment{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.comment"]];

    return [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
}

#pragma mark - Idenifier

- (NSDictionary *) attributesForIdentifierPlain{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.plain"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
}


- (NSDictionary *) attributesForIdentifierClassRef{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.class"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
}

- (NSDictionary *) attributesForIdentifierTypeRef{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.type"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
}

- (NSDictionary *) attributesForIdentifierTypeSystem{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.type.system"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
}

- (NSDictionary *) attributesForIdentifierFunction{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.function"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
}

- (NSDictionary *) attributesForIdentifierFunctionSystem{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.function.system"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifierFunction];
    
    return attributes;
}


- (NSDictionary *) attributesForIdentifierVariable{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.variable"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;

}

- (NSDictionary *) attributesForIdentifierMacro{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.macro"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifier];
    
    return attributes;
    
}

- (NSDictionary *) attributesForIdentifierMacroSystem{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier.macro.system"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    if (!attributes)
        return [self attributesForIdentifierMacro];
    
    return attributes;
    
}
- (NSDictionary *) attributesForIdentifier{
    
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.identifier"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
    
}

#pragma mark - Keyword
- (NSDictionary *) attributesForKeyword{
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.keyword"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;

}

#pragma mark - Literals
#pragma mark Number
- (NSDictionary *) attributesForNumber{
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.number"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
}

#pragma mark Character
- (NSDictionary *) attributesForCharacter {
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.character"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
}

#pragma mark String
- (NSDictionary *) attributesForString{
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.string"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
}

#pragma mark - Plain
- (NSDictionary *) attributesForPlain{
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.plain"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
}

#pragma mark - Preprocessor
- (NSDictionary *) attributesForPreprocessor{
    NSFont *syntaxFontAttribute = [_themaManager fontForKeyPath:@[SourceTextSyntaxFontsKey, @"xcode.syntax.plain"]];
    NSColor *syntaxColorAttribute = [_themaManager colorForKeyPath:@[SourceTextSyntaxColorsKey, @"xcode.syntax.preprocessor"]];
    
    NSDictionary * attributes = [self attributesWithFont:syntaxFontAttribute color:syntaxColorAttribute];
    
    return attributes;
}



#pragma mark - URL
- (NSDictionary *) attributesForURL{
    return nil;
}

#pragma mark - Attributes builders
- (NSDictionary *) attributesWithFont:(NSFont *) font color:(NSColor *) color {

    if (!color || !font)
        return nil;
    
    NSDictionary *codeSyntaxAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{NSFontAttributeName:font,
                                                                                           NSForegroundColorAttributeName:color}];
    return codeSyntaxAttributes;

}

- (NSDictionary *) attributesWithColor:(NSColor *) color{
    
    if (!color)
        return nil;
    
    NSDictionary *codeSyntaxAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{NSForegroundColorAttributeName:color}];
    
    return codeSyntaxAttributes;
    
}

#pragma mark - Helper
- (NSArray *) includesKeyWords {

    static NSArray *keyWords;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyWords = @[@"#", @"include", @"import"];
    });
    
    return keyWords;
}

@end
